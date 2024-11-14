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

    context "when the image fails to save" do
      before do
        # Stubbing the image to return false for save
        allow_any_instance_of(Image).to receive(:save).and_return(false)
        post :create, params: { run_time_object_id: run_time_object.id, image: { tag: 'python:3.4-alpine' } }
      end

      it "does not redirect and renders the 'new' template" do
        expect(response).to render_template(:new)
      end

      it "sets a flash alert message" do
        expect(flash[:alert]).to eq("Error saving the data. Please try again.")
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
    mock_scan_result = <<-TEXT
      {
        "SchemaVersion": 2,
        "CreatedAt": "2024-10-17T23:48:27.295729-05:00",
        "ArtifactName": "selenium/video:ffmpeg-6.1.1-20240517",
        "ArtifactType": "container_image",
        "Results": [
          {
            "Target": "selenium/video:ffmpeg-6.1.1-20240517 (ubuntu 22.04)",
            "Class": "os-pkgs",
            "Type": "ubuntu",
            "Vulnerabilities": [
              {
                "VulnerabilityID": "CVE-2016-2781",
                "InstalledVersion": "8.32-4.1ubuntu1.2",
                "Status": "affected",
                "SeveritySource": "ubuntu",
                "PrimaryURL": "https://avd.aquasec.com/nvd/cve-2016-2781",
                "Title": "coreutils: Non-privileged session can escape to the parent session in chroot",
                "Description": "chroot in GNU coreutils, when used with --userspec, allows local users to escape to the parent session via a crafted TIOCSTI ioctl call, which pushes characters to the terminal's input buffer.",
                "Severity": "LOW",
                "References": [
                  "http://seclists.org/oss-sec/2016/q1/452",
                  "http://www.openwall.com/lists/oss-security/2016/02/28/2",
                  "http://www.openwall.com/lists/oss-security/2016/02/28/3",
                  "https://access.redhat.com/security/cve/CVE-2016-2781",
                  "https://lists.apache.org/thread.html/rf9fa47ab66495c78bb4120b0754dd9531ca2ff0430f6685ac9b07772%40%3Cdev.mina.apache.org%3E",
                  "https://lore.kernel.org/patchwork/patch/793178/",
                  "https://mirrors.edge.kernel.org/pub/linux/utils/util-linux/v2.28/v2.28-ReleaseNotes",
                  "https://nvd.nist.gov/vuln/detail/CVE-2016-2781",
                  "https://www.cve.org/CVERecord?id=CVE-2016-2781"
                ],
                "PublishedDate": "2017-02-07T15:59:00.333Z",
                "LastModifiedDate": "2023-11-07T02:32:03.347Z"
              }
            ]
          },
          {
            "Target": "Python",
            "Class": "lang-pkgs",
            "Type": "python-pkg",
            "Vulnerabilities": [
              {
                "VulnerabilityID": "CVE-2024-6345",
                "InstalledVersion": "69.5.1",
                "FixedVersion": "70.0.0",
                "Status": "fixed",
                "PrimaryURL": "https://avd.aquasec.com/nvd/cve-2024-6345",
                "Title": "pypa/setuptools: Remote code execution via download functions in the package_index module in pypa/setuptools",
                "Description": "A vulnerability in the package_index module of pypa/setuptools versions up to 69.1.1 allows for remote code execution via its download functions. These functions, which are used to download packages from URLs provided by users or retrieved from package index servers, are susceptible to code injection. If these functions are exposed to user-controlled inputs, such as package URLs, they can execute arbitrary commands on the system. The issue is fixed in version 70.0.",
                "Severity": "HIGH",
                "CweIDs": ["CWE-94"],
                "References": [
                  "https://access.redhat.com/errata/RHSA-2024:6726",
                  "https://access.redhat.com/security/cve/CVE-2024-6345",
                  "https://bugzilla.redhat.com/2297771",
                  "https://bugzilla.redhat.com/show_bug.cgi?id=2297771",
                  "https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2024-6345",
                  "https://errata.almalinux.org/9/ALSA-2024-6726.html",
                  "https://errata.rockylinux.org/RLSA-2024:6726",
                  "https://github.com/pypa/setuptools",
                  "https://github.com/pypa/setuptools/commit/88807c7062788254f654ea8c03427adc859321f0",
                  "https://github.com/pypa/setuptools/pull/4332",
                  "https://huntr.com/bounties/d6362117-ad57-4e83-951f-b8141c6e7ca5",
                  "https://linux.oracle.com/cve/CVE-2024-6345.html",
                  "https://linux.oracle.com/errata/ELSA-2024-6726.html",
                  "https://nvd.nist.gov/vuln/detail/CVE-2024-6345",
                  "https://ubuntu.com/security/notices/USN-7002-1",
                  "https://www.cve.org/CVERecord?id=CVE-2024-6345"
                ],
                "PublishedDate": "2024-07-15T01:15:01.73Z",
                "LastModifiedDate": "2024-07-15T13:00:34.853Z"
              }
            ]
          }
        ]
      }
      TEXT
    it 'scans the image based on dynamic tag provided' do
      allow(controller).to receive(:`).and_return(mock_scan_result)
      post :create, params: { run_time_object_id: run_time_object.id, image: { tag: 'python:3.4-alpine' } }
      expect(assigns(:image).report).to have_content("CVE-2016-2781")
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
      expect(assigns(:image_report)).to be_present
    end

    it "response is successful" do
      image = Image.create(tag: "python:3.4-alpine", report: '{"Results":[{"Target":"ABC","Vulnerabilities":[]}]}', run_time_object: run_time_object)
      get :show, params: { run_time_object_id: run_time_object.id, id: image.id }
      expect(response).to be_successful
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
end
