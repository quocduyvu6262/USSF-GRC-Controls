class ImagesController < ApplicationController
  SEVERITY_ORDER = {
  "CRITICAL" => 1,
  "HIGH" => 2,
  "MEDIUM" => 3,
  "LOW" => 4,
  "UNKNOWN" => 5
}
  before_action :set_image, only: %i[ show edit update destroy rescan ]

  # GET /images or /images.json
  def index
    @images = Image.all
  end

  def show
    @tag = params[:id]
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
    @image = Image.new
  end

  # GET /images/1/edit
  def edit
  end

  def create
    # comment
    @user = current_user  # Ensure @user is set
    @image = Image.new(image_params)

    # Fetch the image name from the tag (which is provided as a URL field input)
    image_name = params[:image][:tag]

    # Perform trivy scan for the image from URL
    @image.report = `json_out=$(trivy image --format json #{image_name}) && echo $json_out` # Run trivy scan on the provided image name
    # @image.report&.gsub!(/\e\[([;\d]+)?m/, "")
    puts @image.report

    if @image.save
      redirect_to @image
    else
      redirect_to new_image_path
    end
  end

  def rescan 
    image_name = @image.tag
    begin
        @image.report = `json_out=$(trivy image --format json #{image_name}) && echo $json_out`
        Rails.logger.debug "New Report: #{@image.report}"

        if @image.save
          redirect_to @image
        else
          redirect_to new_image_path
        end
    end
  end

  # PATCH/PUT /images/1 or /images/1.json
  def update
    respond_to do |format|
      if @image.update(image_params)
        format.html { redirect_to @image, notice: "Image was successfully updated." }
        format.json { render :show, status: :ok, location: @image }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @image.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /images/1 or /images/1.json
  def destroy
    @image.destroy!

    respond_to do |format|
      format.html { redirect_to images_path, status: :see_other, notice: "Image was successfully destroyed." }
      format.json { head :no_content }
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
      params.require(:image).permit(:tag, :run_time_object_id, :created_at, :updated_at)
    end
end
