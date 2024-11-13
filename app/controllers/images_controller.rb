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
    @run_time_object = RunTimeObject.find(params[:run_time_object_id])  # Fetch the parent resource
    @image = @run_time_object.images.new(image_params)  # Associate the image with the parent

    image_name = params[:image][:tag]

    # Perform trivy scan for the image from URL
    @image.report = `json_out=$(trivy image --format json #{image_name}) && echo $json_out` # Run trivy scan on the provided image name
    # @image.report&.gsub!(/\e\[([;\d]+)?m/, "")
    # puts @image.report

    if @image.save
      redirect_to run_time_object_image_path(@run_time_object.id, @image), notice: "Image was successfully created."
    else
      render :new
    end
  end

  def rescan
    image_name = @image.tag
    @run_time_object = RunTimeObject.find(params[:run_time_object_id])
    begin
        @image.report = `json_out=$(trivy image --format json #{image_name}) && echo $json_out`
        Rails.logger.debug "New Report: #{@image.report}"

        if @image.save
          redirect_to run_time_object_image_path(@run_time_object.id, @image), notice: "Rescan was successful."
        end
    end
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


    # Only allow a list of trusted parameters through.
    def image_params
      params.require(:image).permit(:tag, :run_time_object_id)
    end
end
