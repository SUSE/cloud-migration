class V1::InspectionExportsController < ApplicationController
  before_action :set_inspection, only: [:new, :create, :update, :archive]
  before_action :set_inspection_export, only: [:show, :edit, :update, :destroy]

  # GET /v1/machines/:machine_fqdn/inspections/:inspection_id/exports/:id/archive
  def archive
    # TODO(gyee): check the export_type here when we start supporting different
    # types of exports
    send_file @inspection.salt_states_archive_name()
  end

  # POST /v1/machines/:machine_fqdn/inspections/:inspection_id/exports
  def create
    export_type = params[:inspection_export][:export_type]
    # TODO(gyee): enhance Machinery to allows unmanaged_files_excludes
    @inspection.export_salt_states()
    # TODO(gyee): should we also include the archive name?
    @inspection.create_salt_states_archive()

    @inspection_export = @inspection.inspection_exports.new(
      inspection_export_params)

    respond_to do |format|
      if @inspection_export.save
        format.json { render json: @inspection_export,
          fqdn: params[:machine_fqdn], status: :created }
      else
        format.json { render json: {
          errors: @inspection_export.errors.full_messages },
          status: :unprocessable_entity }
      end
    end

  rescue Exception => e
    logger.error(e.backtrace.join("\n"))
    logger.error("Unable to create #{export_type} export: #{e.message}")
    respond_to do |format|
      format.json { render json:
        { errors: "Unable to create #{export_type} export: #{e.message}" },
        status: :unprocessable_entity }
    end
  end

  # GET /v1/machines/:machine_fqdn/inspections/:inspection_id/exports
  def index
    @inspection_exports = InspectionExport.all
    respond_to do |format|
      format.json { render json: @inspection_exports,
                    fqdn: params[:machine_fqdn], status: :ok }
    end
  end

  # GET /v1/machines/:machine_fqdn/inspections/:inspection_id/exports/:id
  def show
    respond_to do |format|
      format.json { render json: @inspection_export,
                    fqdn: params[:machine_fqdn], status: :ok }
    end
  end

  # PUT /v1/machines/:machine_fqdn/inspections/:inspection_id/exports/:id
  def update
    # re-export with the new params
    export_type = params[:inspection_export][:export_type]
    # TODO(gyee): enhance Machinery to allows unmanaged_files_excludes
    @inspection.export_salt_states()
    # TODO(gyee): should we also include the archive name?
    @inspection.create_salt_states_archive()

    respond_to do |format|
      if @inspection_export.update(inspection_export_params)
        format.json { render json: @inspection_export,
                      fqdn: params[:machine_fqdn], status: :created }
      else
        format.json { render json: {
          errors: @inspection_export.errors.full_messages },
          status: :unprocessable_entity }
      end
    end

  rescue Exception => e
    logger.error(e.backtrace.join("\n"))
    logger.error("Unable to create #{export_type} export: #{e.message}")
    respond_to do |format|
      format.json { render json:
        { errors: "Unable to create #{export_type} export: #{e.message}" },
        status: :unprocessable_entity }
    end
  end

  # DELETE /v1/machines/:machine_fqdn/inspections/:inspection_id/exports/:id
  def destroy
    @inspection_export.destroy
  end

  private

  def set_inspection
    @inspection = Inspection.find(params[:inspection_id])
  rescue ActiveRecord::RecordNotFound
    respond_to do |format|
      format.json { render json:
        { errors: "Inspection '#{params[:inspection_id]}' not found." },
        status: :not_found }
    end
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_inspection_export
    @inspection_export = InspectionExport.find_by!(params[:id])
  rescue ActiveRecord::RecordNotFound
    respond_to do |format|
      format.json { render json:
        { errors: "Inspection export '#{params[:id]}' not found." },
        status: :not_found }
    end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def inspection_export_params
    params.require(:inspection_export).permit(
      :export_type, :unmanaged_files_excludes
    )
  end

end
