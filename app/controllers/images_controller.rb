class ImagesController < ApplicationController
  before_action :authorize_edit_permission, only: [ :new, :edit, :create, :rescan, :update, :destroy ]
  before_action :authorize_view_permission, only: [ :index, :show ]

  SEVERITY_ORDER = {
  "CRITICAL" => 1,
  "HIGH" => 2,
  "MEDIUM" => 3,
  "LOW" => 4,
  "UNDEFINED" => 5
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
    @image = @run_time_object.images.find(params[:id])
    @image_report = JSON.parse(@image.report)
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
    @run_time_object = RunTimeObject.find(params[:run_time_object_id])  # Fetch the parent resource
    @image = @run_time_object.images.new(image_params)  # Associate the image with the parent

    image_name = params[:image][:tag]

    @image.report = scan_and_save_image(image_name)

    if @image.save
      redirect_to run_time_object_image_path(@run_time_object.id, @image), notice: "Tag was successfully created."
    else
      flash[:alert] = "Error saving the data. Please try again."
      render :new
    end
  end


  def rescan
    image_name = @image.tag
    @run_time_object = RunTimeObject.find(params[:run_time_object_id])
    @image.report = scan_and_save_image(image_name)
    Rails.logger.debug "New Report: #{@image.report}"

    if @image.save
      redirect_to run_time_object_image_path(@run_time_object.id, @image)
      flash[:notice] ="Rescan was successful."
    end
  end

  def download
    unless @image.report.present?
      flash[:alert] = "No report available for this image."
      redirect_to run_time_object_image_path(@image.run_time_object, @image) and return
    end
    image_report = JSON.parse(@image.report)

    csv_content = CSV.generate(headers: true) do |csv|
      csv << [ "Target", "Title", "Severity", "ID", "Installed Version", "Fixed Version", "Status", "NIST Identifiers", "Description" ]

      image_report["Results"].each do |result|
        target = result["Target"]

        next if result["Vulnerabilities"].nil? || result["Vulnerabilities"].blank?

        result["Vulnerabilities"].each do |vuln|
          title = vuln["Title"] || "N/A"
          severity = vuln["Severity"] || "N/A"
          id = vuln["VulnerabilityID"] || "N/A"
          installed_version = vuln["InstalledVersion"] || "N/A"
          fixed_version = vuln["FixedVersion"] || "N/A"
          status = vuln["Status"] || ""
          nist_identifiers = (vuln["NISTControlIdentifiers"] || []).join(", ") || "N/A"
          description = (vuln["Description"] || "").gsub(/<\/?[^>]+?>/, "").strip || "N/A"

          csv << [ target, title, severity, id, installed_version, fixed_version, status, nist_identifiers, description ]
        end
      end
    end

    # Sanitize the image tag to create a safe file name
    new_name = @image.tag.gsub(/[^0-9A-Za-z.\-]/, "_")

    # Send the generated CSV file as a download
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
      @image.report = scan_and_save_image(image_name)
      if @image.save
        redirect_to run_time_object_image_path(@run_time_object.id, @image), notice: "Tag was successfully updated."
      else
        flash[:alert] = "Error saving the data. Please try again."
        render :new
      end
    end
  end

  def destroy
    @run_time_object = RunTimeObject.find(params[:run_time_object_id])
    @image = @run_time_object.images.find(params[:id])

    @image.destroy

    redirect_to run_time_object_images_path(@run_time_object), notice: "Tag was successfully deleted."
  end

  def authorize_view_permission
    @run_time_object = RunTimeObject.find(params[:run_time_object_id])
    user_obj = User.find(session[:user_id])
    unless @run_time_object.user == user_obj ||
      @run_time_object.run_time_objects_permissions.exists?(user_id: user_obj.id, permission: "r") ||
      @run_time_object.run_time_objects_permissions.exists?(user_id: user_obj.id, permission: "e")
      flash[:alert] = "You are not authorized to view this data."
      redirect_to run_time_objects_path
    end
  end

  def authorize_edit_permission
    @run_time_object = RunTimeObject.find(params[:run_time_object_id])
    user_obj = User.find(session[:user_id])
    unless @run_time_object.user == user_obj || @run_time_object.run_time_objects_permissions.exists?(user_id: user_obj.id, permission: "e")
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

    def scan_and_save_image(image_name)
      # Perform trivy scan for the image from URL
      report = `json_out=$(trivy image --format json #{image_name}) && echo $json_out` # Run trivy scan

      begin
        report = JSON.parse(report.gsub(/\e\[([;\d]+)?m/, "").gsub(/\n/, "").gsub(/[\u0000-\u001F]/, "").gsub("UNKNOWN", "UNDEFINED"))
      rescue JSON::ParserError => e
        Rails.logger.error "JSON parsing failed: #{e.message}"
        flash[:alert] = "Parsing the report failed. Try again."
        return
      end

      # Map CVEs to NIST controls
      cve_to_nist_mapping = CveNistMapping.pluck(:cve_id, :nist_control_identifiers).to_h

      # Process vulnerabilities in the report
      report["Results"].each do |result|
        next if result["Vulnerabilities"].nil? || result["Vulnerabilities"].blank?


        result["Vulnerabilities"].each do |vuln|
          # Add NIST Control Identifiers to each vulnerability
          vuln["NISTControlIdentifiers"] = cve_to_nist_mapping[vuln["VulnerabilityID"]] || []
        end

        # Sort vulnerabilities by severity and generate a summary
        result["Vulnerabilities"].sort_by! { |vuln| SEVERITY_ORDER[vuln["Severity"]] || 99 }
        result["VulnerabilitySummary"] = result["Vulnerabilities"].group_by { |v| v["Severity"] }
                                                                    .transform_values(&:count)
        result["FixableVulnerabilitiesCount"] = result["Vulnerabilities"].count { |v| v["FixedVersion"].present? }
      end

      report.to_json
    end

    # Only allow a list of trusted parameters through.
    def image_params
      params.require(:image).permit(:tag, :run_time_object_id)
    end
end
