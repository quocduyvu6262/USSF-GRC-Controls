require 'rails_helper'

RSpec.describe ImagesController, type: :controller do
  let(:user) { User.create(email: "test@example.com", first_name: "Test", last_name: "User") }
  let(:shared_user) { User.create(email: "dummy@example.com", first_name: "Dummy", last_name: "User") }

  let(:run_time_object) { RunTimeObject.create(name: "Sample Object", description: "A sample runtime object", user: user) }
  let(:image) { Image.create(tag: "alpine", run_time_object: run_time_object) }
  let(:valid_json_report) do
    '{"Results": [{"Target": "example", "Vulnerabilities": [{"VulnerabilityID": "CVE-2023-0001", "Title": "Sample Vulnerability", "Severity": "HIGH", "InstalledVersion": "1.0", "FixedVersion": "1.1", "Status": "affected", "Description": "A vulnerability description."}]}]}'
  end
  let(:invalid_json_report) { "{invalid JSON}" }

  let(:private_registry_image) { "private.azurecr.io/myapp:latest" }
  let(:valid_credentials) { { registry_username: "validuser", registry_password: "validpass" } }
  let(:invalid_credentials) { { registry_username: "invaliduser", registry_password: "invalidpass" } }

  # Mock successful Trivy output
  let(:successful_trivy_output) { '{"Results":[{"Vulnerabilities":[]}]}' }
  # Mock authentication failure Trivy output
  let(:auth_failure_output) { "unauthorized: authentication required" }
  # Mock connection failure Trivy output
  let(:connection_failure_output) { "connection refused" }

  before do
    session[:user_id] = user.id
    RunTimeObject.destroy_all
    Image.destroy_all
  end

  describe "images index" do
    it "returns a successful response" do
      get :index, params: { run_time_object_id: run_time_object.id }
      expect(response).to be_successful
    end

    context "shared and unauthorized users access runtime object" do
      before do
        session[:user_id] = shared_user.id
      end

      it "returns a successful response for shared user with view permission" do
        RunTimeObjectsPermission.create(run_time_object: run_time_object, user_id: shared_user.id, permission: "r")
        get :index, params: { run_time_object_id: run_time_object.id }
        expect(response).to be_successful
      end

      it "returns a successful response for shared user with edit permission" do
        RunTimeObjectsPermission.create(run_time_object: run_time_object, user_id: shared_user.id, permission: "e")
        get :index, params: { run_time_object_id: run_time_object.id }
        expect(response).to be_successful
      end

      it "redirect to homepage for unauthorized user" do
        get :index, params: { run_time_object_id: run_time_object.id }
        expect(response).to redirect_to(run_time_objects_path)
      end
    end
  end

  describe "creates" do
    it 'creates image with valid parameters' do
      post :create, params: { run_time_object_id: run_time_object.id, image: {
        tag: 'alpine',
        run_time_object_id: run_time_object.id
      } }
      expect(response).to redirect_to(run_time_object_image_path(run_time_object.id, Image.last))
    end

    it 'creates image with invalid parameters' do
      post :create, params: { run_time_object_id: run_time_object.id, image: {
        tag: '',
        run_time_object_id: ''
      } }
      expect(response).to redirect_to(run_time_object_image_path(run_time_object.id, Image.last))
    end

    context "shared and unauthorized users try to create/edit image" do
      before do
        session[:user_id] = shared_user.id
      end

      it "redirect for shared user with view permission" do
        RunTimeObjectsPermission.create(run_time_object: run_time_object, user_id: shared_user.id, permission: "r")
        post :create, params: { run_time_object_id: run_time_object.id, image: {
          tag: '',
          run_time_object_id: ''
        } }
        expect(response).to redirect_to(run_time_objects_path)
      end

      it "returns a successful response for shared user with edit permission" do
        RunTimeObjectsPermission.create(run_time_object: run_time_object, user_id: shared_user.id, permission: "e")
        post :create, params: { run_time_object_id: run_time_object.id, image: {
          tag: '',
          run_time_object_id: ''
        } }
        expect(response).to redirect_to(run_time_object_image_path(run_time_object.id, Image.last))
      end
    end
  end

  describe "update" do
    it "updates image with valid parameters" do
      image = Image.create(tag: "alpine", run_time_object: run_time_object)
      put :update, params: { run_time_object_id: run_time_object.id, id: image.id, image: { tag: "ubuntu" } }
      image.reload
      expect(image.tag).to eq("ubuntu")
    end
  end

  describe "destroy" do
    it "destroys the requested image" do
      image = Image.create(tag: "alpine", run_time_object: run_time_object)
      expect {
        delete :destroy, params: { run_time_object_id: run_time_object.id, id: image.to_param }
      }.to change(Image, :count).by(-1)
    end
  end
  ######
  describe "create with dynamic image name" do
    it 'scans the image based on dynamic tag provided' do
      allow(controller).to receive(:`).and_return("Mock scan result")
      post :create, params: { run_time_object_id: run_time_object.id, image: { tag: 'python:3.4-alpine' } }
      expect(assigns(:image).report).to eq("Mock scan result")
    end

    it 'redirects to right page' do
      allow(controller).to receive(:`).and_return("Mock scan result")
      post :create, params: { run_time_object_id: run_time_object.id, image: { tag: 'python:3.4-alpine' } }
      expect(response).to redirect_to(run_time_object_image_path(run_time_object.id, Image.last))
    end
  end

  describe "show" do
    it "displays the report for a scanned image" do
      image = Image.create(tag: "python:3.4-alpine", report: '{"Results":[{"Target":"ABC","Vulnerabilities":[{"VulnerabilityID": "CVE-2016-2781", "FixedVersion": "1.1.1"}]}]}', run_time_object: run_time_object)
      get :show, params: { run_time_object_id: run_time_object.id, id: image.id }
      expect(assigns(:vulnerability_summary)).to be_present
    end

    it "response is successful" do
      image = Image.create(tag: "python:3.4-alpine", report: '{"Results":[{"Target":"ABC","Vulnerabilities":[]}]}', run_time_object: run_time_object)
      get :show, params: { run_time_object_id: run_time_object.id, id: image.id }
      expect(response).to be_successful
    end
  end

  describe "create without running scan" do
    it 'creates image without running a scan' do
      allow(controller).to receive(:`).and_return(nil)  # No scan is performed
      post :create, params: { run_time_object_id: run_time_object.id, image: { tag: 'ubuntu:latest' } }
      expect(assigns(:image).report).to be_nil
    end

    it 'redirects to right page' do
      allow(controller).to receive(:`).and_return(nil)  # No scan is performed
      post :create, params: { run_time_object_id: run_time_object.id, image: { tag: 'ubuntu:latest' } }
      expect(response).to redirect_to(run_time_object_image_path(run_time_object.id, Image.last))
    end
  end

  describe "new" do
    it "sets the correct user for new action" do
      get :new, params: { run_time_object_id: run_time_object.id }
      expect(assigns(:user)).to eq(user)
    end

    it "renders the new template" do
      get :new, params: { run_time_object_id: run_time_object.id }
      expect(response).to render_template(:new)
    end
  end

  describe "response formats" do
    it "returns HTML format for show" do
      image = Image.create(tag: "python:3.4-alpine", report: '{"Results":[{"Target":"ABC","Vulnerabilities":[]}]}', run_time_object: run_time_object)
      get :show, params: { run_time_object_id: run_time_object.id, id: image.id }, format: :html
      expect(response.content_type).to eq("text/html; charset=utf-8")
    end
  end

  describe "rescan" do
    let!(:image) { Image.create(tag: "alpine", run_time_object: run_time_object) }

    before do
      allow(controller).to receive(:current_user).and_return(user)
    end

    context 'when the scan is successful' do
      before do
        allow(controller).to receive(:`).and_return('{"Results":[]}') # Mocking the scan output
        post :rescan, params: { run_time_object_id: run_time_object.id, id: image.id }
      end

      it 'updates the image report' do
        image.reload
        expect(image.report).to eq('{"Results":[]}')
      end

      it 'redirects to the image show page' do
        expect(response).to redirect_to(run_time_object_image_path(run_time_object.id, image))
        expect(flash[:notice]).to eq("Rescan was successful.")
      end
    end
  end

  describe "GET #download" do
    context "when the report is valid JSON" do
      before do
        image.update(report: valid_json_report)
      end

      it "returns a CSV file" do
        get :download, params: { run_time_object_id: run_time_object.id, id: image.id }
        expect(response.headers['Content-Type']).to include 'text/csv'
        expect(response.headers['Content-Disposition']).to include 'attachment'
      end

      it "includes the correct CSV headers" do
        get :download, params: { run_time_object_id: run_time_object.id, id: image.id }
        csv_data = CSV.parse(response.body, headers: true)
        expect(csv_data.headers).to include("Title", "Severity", "ID", "Installed Version", "Fixed Version", "Status", "NIST Identifiers", "Description")
      end

      it "includes vulnerability data in the CSV" do
        get :download, params: { run_time_object_id: run_time_object.id, id: image.id }
        csv_data = CSV.parse(response.body, headers: true)
        expect(csv_data[0]["Title"]).to eq("Sample Vulnerability")
      end
    end

    context "when the report is invalid JSON" do
      before do
        image.update(report: invalid_json_report)
      end

      it "redirects to the image show page with an alert" do
        get :download, params: { run_time_object_id: run_time_object.id, id: image.id }
        expect(response).to redirect_to(run_time_object_image_path(run_time_object, image))
        expect(flash[:alert]).to eq("Failed to parse the report. Invalid JSON format.")
      end
    end

    context "when the report is nil" do
      before do
        image.update(report: nil)
      end

      it "redirects to the image show page with an alert" do
        get :download, params: { run_time_object_id: run_time_object.id, id: image.id }
        expect(response).to redirect_to(run_time_object_image_path(run_time_object, image))
        expect(flash[:alert]).to eq("No report available for this image.")
      end
    end
  end
  #####
  describe "private registry operations" do
    describe "create with private registry" do
      context "with valid credentials" do
        let(:successful_trivy_output) { '{"Results": []}' }

      it "creates image successfully" do
        # Mock the registry validation
        allow(controller).to receive(:valid_registry_credentials?)
          .with(private_registry_image, valid_credentials[:registry_username], valid_credentials[:registry_password])
          .and_return(true)

        # Mock is_private_registry? check
        allow(controller).to receive(:is_private_registry?)
          .with(private_registry_image)
          .and_return(true)

        # Mock the command generation
        allow(controller).to receive(:generate_trivy_scan_command)
          .with(private_registry_image, valid_credentials[:registry_username], valid_credentials[:registry_password])
          .and_return("trivy command string")

        # Create a fake status object
        process_status = instance_double(Process::Status, success?: true)

        # Mock the kernel backtick method and process status together
        allow(controller).to receive(:`)
          .with("trivy command string") do
            # Stub $? for this specific call
            allow(Process).to receive(:last_status).and_return(process_status)
            successful_trivy_output
          end

        expect {
          post :create, params: {
            run_time_object_id: run_time_object.id,
            image: { tag: private_registry_image },
            registry_username: valid_credentials[:registry_username],
            registry_password: valid_credentials[:registry_password]
          }
        }.to change(Image, :count).by(1)

        expect(Image.last).to be_present
        expect(Image.last.tag).to eq(private_registry_image)
        expect(response).to redirect_to(run_time_object_image_path(run_time_object.id, Image.last))
        expect(flash[:notice]).to eq("Image was successfully created.")
      end
    end

      context "with invalid credentials" do
        it "fails to create image" do
          # Mock the validation to fail
          allow(controller).to receive(:valid_registry_credentials?)
            .with(private_registry_image, invalid_credentials[:registry_username], invalid_credentials[:registry_password])
            .and_return(false)

          expect {
            post :create, params: {
              run_time_object_id: run_time_object.id,
              image: { tag: private_registry_image },
              registry_username: invalid_credentials[:registry_username],
              registry_password: invalid_credentials[:registry_password]
            }
          }.not_to change(Image, :count)

          expect(response).to render_template(:new)
          expect(assigns(:image).errors[:base]).to include("Invalid registry credentials or the registry is inaccessible.")
        end
      end

      context "with missing credentials" do
        it "fails to create image" do
          expect {
            post :create, params: {
              run_time_object_id: run_time_object.id,
              image: { tag: private_registry_image }
            }
          }.not_to change(Image, :count)

          expect(response).to render_template(:new)
          expect(assigns(:image).errors[:base]).to include("Username and password are required for private registries.")
        end
      end
    end

    describe "rescan with private registry" do
      let(:image) { Image.create(tag: private_registry_image, run_time_object: run_time_object) }

      context "with valid credentials" do
        it "rescans image successfully" do
          # Mock the private registry check
          allow(controller).to receive(:is_private_registry?)
            .with(private_registry_image)
            .and_return(true)

          # Mock the registry validation
          allow(controller).to receive(:valid_registry_credentials?)
            .with(private_registry_image, valid_credentials[:registry_username], valid_credentials[:registry_password])
            .and_return(true)

          # Mock the command generation
          allow(controller).to receive(:generate_trivy_scan_command)
            .with(private_registry_image, valid_credentials[:registry_username], valid_credentials[:registry_password])
            .and_return("trivy command string")

          # Create a fake status object
          process_status = instance_double(Process::Status, success?: true)

          # Mock the kernel backtick method and process status together
          allow(controller).to receive(:`)
            .with("trivy command string") do
              allow(Process).to receive(:last_status).and_return(process_status)
              successful_trivy_output
            end

          post :rescan, params: {
            run_time_object_id: run_time_object.id,
            id: image.id,
            registry_username: valid_credentials[:registry_username],
            registry_password: valid_credentials[:registry_password]
          }

          expect(response).to redirect_to(run_time_object_image_path(run_time_object.id, image))
          expect(flash[:notice]).to eq("Rescan was successful.")

          image.reload
          expect(image.report).to eq(successful_trivy_output)
        end
      end

      context "with invalid credentials" do
        it "fails to rescan image" do
          # Mock the private registry check
          allow(controller).to receive(:is_private_registry?)
            .with(private_registry_image)
            .and_return(true)

          # Mock the registry validation to fail
          allow(controller).to receive(:valid_registry_credentials?)
            .with(private_registry_image, invalid_credentials[:registry_username], invalid_credentials[:registry_password])
            .and_return(false)

          post :rescan, params: {
            run_time_object_id: run_time_object.id,
            id: image.id,
            registry_username: invalid_credentials[:registry_username],
            registry_password: invalid_credentials[:registry_password]
          }

          expect(response).to redirect_to(run_time_object_image_path(run_time_object, image))
          expect(flash[:alert]).to eq("Invalid registry credentials or registry not accessible")
        end
      end

      context "with missing credentials" do
        it "fails to rescan image" do
          # Mock the private registry check
          allow(controller).to receive(:is_private_registry?)
            .with(private_registry_image)
            .and_return(true)

          post :rescan, params: {
            run_time_object_id: run_time_object.id,
            id: image.id
          }

          expect(response).to redirect_to(run_time_object_image_path(run_time_object, image))
          expect(flash[:alert]).to eq("Username and password are required for private registries")
        end
      end

      context "with public registry" do
        it "rescans without requiring credentials" do
          # Mock the private registry check to return false
          allow(controller).to receive(:is_private_registry?)
            .with(private_registry_image)
            .and_return(false)

          # Mock the command generation without credentials
          allow(controller).to receive(:generate_trivy_scan_command)
            .with(private_registry_image)
            .and_return("trivy command string")

          # Create a fake status object
          process_status = instance_double(Process::Status, success?: true)

          # Mock the kernel backtick method and process status together
          allow(controller).to receive(:`)
            .with("trivy command string") do
              allow(Process).to receive(:last_status).and_return(process_status)
              successful_trivy_output
            end

          post :rescan, params: {
            run_time_object_id: run_time_object.id,
            id: image.id
          }

          expect(response).to redirect_to(run_time_object_image_path(run_time_object.id, image))
          expect(flash[:notice]).to eq("Rescan was successful.")

          image.reload
          expect(image.report).to eq(successful_trivy_output)
        end
      end
    end
  end
end
