require "net/http"
require "uri"
require "base64"

class ImagesController < ApplicationController
  before_action :authorize_edit_permission, only: [ :new, :edit, :create, :rescan, :update, :destroy ]
  before_action :authorize_view_permission, only: [ :index, :show ]

  SEVERITY_ORDER = {
  "CRITICAL" => 1,
  "HIGH" => 2,
  "MEDIUM" => 3,
  "LOW" => 4,
  "UNKNOWN" => 5
}
  before_action :set_image, only: %i[ show edit update destroy rescan download ]

  # GET /images or /images.json
  def index
    @run_time_object = RunTimeObject.find(params[:run_time_object_id])  # Fetch the RunTimeObject
    @images = @run_time_object.images  # Get images associated with that RunTimeObject
    @pagy, @images = pagy(@images)
  end

  def show
    @tag = params[:id]
    @run_time_object = RunTimeObject.find(params[:run_time_object_id])
    @user = current_user
    begin
      @image_report = JSON.parse(@image.report.gsub(/\e\[([;\d]+)?m/, "").gsub(/\n/, "").gsub(/[\u0000-\u001F]/, ""))
    rescue JSON::ParserError
      @image_report = { "Results" => [ { "Target" => @image.report, "Vulnerabilities" => [] } ] }
    end

    cve_to_nist_mapping = CveNistMapping.pluck(:cve_id, :nist_control_identifiers).to_h

    @vulnerability_summary = {}
    @fixable_vulnerabilities_count = 0
    @image_report["Results"].each do |result|
      target = result["Target"]
      next if result["Vulnerabilities"].nil?

      result["Vulnerabilities"].each do |vuln|
        # Add NIST Control Identifiers to each vulnerability
        cve_id = vuln["VulnerabilityID"]
        vuln["NISTControlIdentifiers"] = cve_to_nist_mapping[cve_id] || []
        if vuln["FixedVersion"].present? && vuln["FixedVersion"] != ""
          @fixable_vulnerabilities_count += 1
        end
      end

      result["Vulnerabilities"].sort_by! { |vuln| SEVERITY_ORDER[vuln["Severity"]] || 99 }
      @vulnerability_summary[target] = result["Vulnerabilities"].group_by { |v| v["Severity"] }
                                                                .transform_values(&:count)
    end
  end


  def new
    @user = current_user
    @run_time_object = RunTimeObject.find(params[:run_time_object_id])
    @image = Image.new
  end

  # GET /images/1/edit
  def edit
    @run_time_object = RunTimeObject.find(params[:run_time_object_id])
    @image = @run_time_object.images.find(params[:id])
  end

  def create
    @run_time_object = RunTimeObject.find(params[:run_time_object_id])
    @image = @run_time_object.images.new(image_params)
    image_name = params[:image][:tag]

    if is_private_registry?(image_name)
      username = params[:registry_username]
      password = params[:registry_password]

      if username.blank? || password.blank?
        @image.errors.add(:base, "Username and password are required for private registries.")
        return render :new
      end

      unless valid_registry_credentials?(image_name, username, password)
        @image.errors.add(:base, "Invalid registry credentials or the registry is inaccessible.")
        return render :new
      end

      scan_command = generate_trivy_scan_command(image_name, username, password)
    else
      scan_command = generate_trivy_scan_command(image_name)
    end

    #Rails.logger.debug "Executing scan command: #{scan_command}"
    scan_result = `#{scan_command}`
    success = $?.success?

    # if success
    @image.report = scan_result
    if @image.save
      redirect_to run_time_object_image_path(@run_time_object.id, @image),
                  notice: "Image was successfully created."
    else
      render :new
    end
    # else
    #   @image.errors.add(:base, "Failed to scan the image. Please verify the image exists and is accessible.")
    #   render :new
    # end
  end

  def rescan
    image_name = @image.tag
    @run_time_object = RunTimeObject.find(params[:run_time_object_id])

    if is_private_registry?(image_name)
      username = params[:registry_username]
      password = params[:registry_password]

      if username.blank? || password.blank?
        return redirect_to run_time_object_image_path(@run_time_object, @image),
                          alert: "Username and password are required for private registries"
      end

      unless valid_registry_credentials?(image_name, username, password)
        return redirect_to run_time_object_image_path(@run_time_object, @image),
                          alert: "Invalid registry credentials or registry not accessible"
      end

      scan_command = generate_trivy_scan_command(image_name, username, password)
    else
      scan_command = generate_trivy_scan_command(image_name)
    end

    #Rails.logger.debug "Executing rescan command: #{scan_command}"
    scan_result = `#{scan_command}`

    # if $?.success?
    @image.report = scan_result
    if @image.save
      redirect_to run_time_object_image_path(@run_time_object.id, @image),
                  notice: "Rescan was successful."
    end
    # else
    #   redirect_to run_time_object_image_path(@run_time_object, @image),
    #               alert: "Failed to rescan image. Please verify the image exists and is accessible."
    # end
  end

  def download
    unless @image.report.present?
      flash[:alert] = "No report available for this image."
      redirect_to run_time_object_image_path(@image.run_time_object, @image) and return
    end

    begin
      @image_report = JSON.parse(@image.report.gsub(/\e\[([;\d]+)?m/, "").gsub(/\n/, "").gsub(/[\u0000-\u001F]/, ""))
    rescue JSON::ParserError
      flash[:alert] = "Failed to parse the report. Invalid JSON format."
      redirect_to run_time_object_image_path(@image.run_time_object, @image) and return
    end

    # Process and generate CSV content
    cve_to_nist_mapping = CveNistMapping.pluck(:cve_id, :nist_control_identifiers).to_h
    vulnerabilities_data = []

    @image_report["Results"].each do |result|
      target = result["Target"]
      next if result["Vulnerabilities"].nil?

      result["Vulnerabilities"].each do |vuln|
        nist_ids = (cve_to_nist_mapping[vuln["VulnerabilityID"]] || []).map do |nist_id|
          parts = nist_id.split("/")
          if parts.length == 2
            ActionController::Base.helpers.link_to(
              nist_id,
              "https://csf.tools/reference/nist-sp-800-53/r4/#{parts[0].downcase}/#{nist_id.downcase}/",
              target: "_blank", class: "nist-link"
            ).to_s
          else
            "<span class='nist-id'>#{nist_id}</span>"
          end
        end.join(" ")

        vulnerabilities_data << {
          title: vuln["Title"] || "N/A",
          severity: vuln["Severity"] || "N/A",
          id: vuln["VulnerabilityID"] || "N/A",
          installed_version: vuln["InstalledVersion"] || "N/A",
          fixed_version: vuln["FixedVersion"] || "N/A",
          status: vuln["Status"] || "",
          nist_identifiers: nist_ids,
          description: vuln["Description"].to_s.gsub(/<\/?[^>]+?>/, "").strip || "N/A"
        }
      end
    end

    csv_content = CSV.generate(headers: true) do |csv|
      csv << [ "Title", "Severity", "ID", "Installed Version", "Fixed Version", "Status", "NIST Identifiers", "Description" ]
      vulnerabilities_data.each do |vuln|
        csv << [
          vuln[:title],
          vuln[:severity],
          vuln[:id],
          vuln[:installed_version],
          vuln[:fixed_version],
          vuln[:status],
          vuln[:nist_identifiers],
          vuln[:description]
        ]
      end
    end

    new_name = @image.tag.gsub(/[^0-9A-Za-z.\-]/, "_")
    send_data csv_content,
              filename: "vulnerability_report_#{new_name}.csv",
              type: "text/csv",
              disposition: "attachment"
  end

  # PATCH/PUT /images/1 or /images/1.json
  def update
    @run_time_object = RunTimeObject.find(params[:run_time_object_id])
    @image = @run_time_object.images.find(params[:id])

    if @image.update(image_params)
      image_name = @image.tag
      @image.report = `json_out=$(trivy image --format json #{image_name}) && echo $json_out`
      @image.save
      redirect_to run_time_object_image_path(@run_time_object.id, @image), notice: "Image was successfully updated."
    end
  end

  def destroy
    @run_time_object = RunTimeObject.find(params[:run_time_object_id])
    @image = @run_time_object.images.find(params[:id])

    @image.destroy

    redirect_to run_time_object_images_path(@run_time_object), notice: "Image was successfully deleted."
  end

  def authorize_view_permission
    @run_time_object = RunTimeObject.find(params[:run_time_object_id])
    user_obj = User.find(session[:user_id])
    unless user_obj.admin? || @run_time_object.user == user_obj ||
      @run_time_object.run_time_objects_permissions.exists?(user_id: user_obj.id, permission: "r") ||
      @run_time_object.run_time_objects_permissions.exists?(user_id: user_obj.id, permission: "e")
      flash[:alert] = "You are not authorized to view this data."
      redirect_to run_time_objects_path
    end
  end

  def authorize_edit_permission
    @run_time_object = RunTimeObject.find(params[:run_time_object_id])
    user_obj = User.find(session[:user_id])
    unless user_obj.admin? || @run_time_object.user == user_obj || @run_time_object.run_time_objects_permissions.exists?(user_id: user_obj.id, permission: "e")
      flash[:alert] = "You are not authorized to edit this data."
      redirect_to run_time_objects_path
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_image
      @image = Image.find(params[:id])
      Rails.logger.debug "Image found: #{@image.inspect}"
    end


    # Only allow a list of trusted parameters through.
    def image_params
      params.require(:image).permit(:tag, :run_time_object_id)
    end

    def extract_registry_from_image(image_name)
      # Split the image name and return the registry portion
      parts = image_name.split('/')
      return parts[0] if parts.size > 1 && (parts[0].include?('.') || parts[0].include?(':'))
      'registry-1.docker.io' # Default to Docker Hub's actual registry hostname
    end
    
    def valid_registry_credentials?(image_name, username, password)
      registry = extract_registry_from_image(image_name)
      
      # Special handling for Docker Hub
      if registry == "docker.io"
        registry = "registry-1.docker.io"
      end
      
      auth_url = if registry.include?("localhost") || registry.match?(/:\d+$/)
                   "http://#{registry}/v2/"
                 else
                   "https://#{registry}/v2/"
                 end
    
      begin
        uri = URI(auth_url)
        request = Net::HTTP::Get.new(uri)
        
        # For Docker Hub, we need to handle authentication differently
        if registry == "registry-1.docker.io"
          # First, get the Bearer token
          token_url = "https://auth.docker.io/token?service=registry.docker.io&scope=repository:#{username}/nginx:pull"
          token_uri = URI(token_url)
          token_request = Net::HTTP::Get.new(token_uri)
          token_request.basic_auth(username, password)
          
          token_response = Net::HTTP.start(token_uri.hostname, token_uri.port, use_ssl: true) do |http|
            http.request(token_request)
          end
          
          if token_response.code.to_i == 200
            token = JSON.parse(token_response.body)["token"]
            request["Authorization"] = "Bearer #{token}"
          else
            Rails.logger.error "Failed to obtain token: #{token_response.code} - #{token_response.body}"
            return false
          end
        else
          # For other registries, use basic auth
          request.basic_auth(username, password)
        end
    
        response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
          if registry == "registry-1.docker.io"
            http.verify_mode = OpenSSL::SSL::VERIFY_PEER
          end
          http.request(request)
        end
    
        case response.code.to_i
        when 200, 401
          # 401 is expected for Docker Hub as it requires token authentication
          Rails.logger.info "Successfully connected to registry: #{registry}"
          true
        when 301, 302, 307, 308
          # Handle redirects
          redirect_uri = URI(response['location'])
          Rails.logger.info "Following redirect to: #{redirect_uri}"
          redirect_response = Net::HTTP.get_response(redirect_uri)
          redirect_response.code.to_i == 200
        else
          Rails.logger.error "Unexpected response from registry: #{response.code} - #{response.body}"
          false
        end
      rescue SocketError => e
        Rails.logger.error "Unable to connect to registry: #{registry} - #{e.message}"
        false
      rescue StandardError => e
        Rails.logger.error "Error connecting to registry: #{registry} - #{e.message}"
        false
      end
    end


    def is_private_registry?(image_name)
      return false if image_name.blank?

      public_patterns = [
          /^quay\.io/,                 # Quay.io
          /^[^\/]+$/,                  # Short image names (e.g., "nginx", "python")
          /^gcr\.io\/google-containers/ # Google official containers
        ]

      # Check if it matches a public registry
      return false if public_patterns.any? { |pattern| image_name.match?(pattern) }


      private_patterns = [
        /^localhost(:\d+)?/,                         # localhost[:port]
        /\.azurecr\.io/,                            # Azure Container Registry
        /\.dkr\.ecr\..*\.amazonaws\.com/,           # AWS ECR
        /^gcr\.io/,                                 # Google Container Registry
        /\.jfrog\.io/,                             # JFrog Artifactory
        /\.registry\./,                             # Generic private registry
        /^harbor\./,                                # Harbor
        /^nexus\./,                                 # Nexus
        /:[\d]+/,                                    # Any registry with port number
        /^docker\.io/,
      ]

      # Check if image name matches any private registry pattern
      private_patterns.any? { |pattern| image_name.match?(pattern) }
    end

    def generate_trivy_scan_command(image_name, username = nil, password = nil)
      command = [ "TRIVY_NON_SSL=true" ]

      if username && password
        command << "TRIVY_USERNAME=#{username}"
        command << "TRIVY_PASSWORD=#{password}"
      end

      command << "trivy image --format json --insecure #{image_name}"

      "json_out=$(#{command.join(' ')}) && echo $json_out"
    end
end
