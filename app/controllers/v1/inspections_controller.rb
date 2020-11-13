class V1::InspectionsController < ApplicationController
  before_action :set_machine,    only: [:new, :create, :show, :index]
  before_action :set_inspection, only: [:show, :destroy, :manifest,
    :update_manifest, :start_inspection]

  # GET /v1/machines/:machine_fqdn/inspections/:id
  def show()
    # NOTE(gyee): don't remove this code. Took me awhile to google this.
    #url_helpers = Rails.application.routes.named_routes.helper_names
    #logger.debug("------ #{url_helpers}")

    respond_to do |format|
      format.json { render json: @inspection,
                    fqdn: params[:machine_fqdn], status: :ok }
    end
  end

  # GET /v1/machines/:machine_fqdn/inspections
  def index
    @inspections = Inspection.all
    respond_to do |format|
      format.json { render json: @inspections,
                    fqdn: params[:machine_fqdn], status: :ok }
    end
  end

  # GET /v1/machines/:machine_fqdn/inspections/:id/manifest
  def manifest()
    respond_to do |format|
      if @inspection["description"]
        format.json { render json: @inspection["description"], status: :ok }
      else
        format.json { render status: :not_found }
      end
    end
  end

  # PUT /v1/machines/:machine_fqdn/inspections/:id/manifest
  def update_manifest
    manifest = @inspection.params_to_manifest(params)
    @inspection.update(description: manifest)
    @inspection.update_manifest(manifest)
    respond_to do |format|
      format.json { render json: @inspection,
                    fqdn: params[:machine_fqdn], status: :ok }
    end
  end

  # POST /v1/machines/:machine_fqdn/inspections
  def create
    # NOTE(gyee): need to peel off the filters from the params
    # so it doesn't trip the permitted flag. Filters are optional
    # when creating an inspection and they are being stored in a
    # different table.
    inspection_filters = params["inspection"].delete("filters")

    @inspection = @machine.inspections.new(inspection_params)
    respond_to do |format|
      if @inspection.save
        if inspection_filters
          logger.debug("Creating filters for inspection #{@inspection.id}")
          
          # FIXME(gyee): this need to be an atomic operation
          create_inspection_filters(inspection_filters)
        end
        @inspection.update(status: 'Scheduling analysis')
        @inspection.delay(queue: @inspection.id).inspect_scopes
        format.json { render json: @inspection, fqdn: params[:machine_fqdn],
                      status: :created }
      else
        format.json { render json: { errors: @inspection.errors },
                      status: :unprocessable_entity }
      end
    end
  end

  # Allow users to optionally include additional inspection filters.
  def create_inspection_filters(filters)

    # TODO(gyee): need to figure out a way to rollback all the transactions
    # if unable to create any filters.
    # Also, should we skip filter creation if there's already one that has
    # the exact same scope and definition. Though have multiple of them is
    # harmless as far as Machinery is concerned.

    filters.each do |filter|
      inspection_filter_params = ActionController::Parameters.new(
        inspection_filter: {
          scope: filter[:scope],
          definition: filter[:definition]})
      inspection_filter_params = inspection_filter_params.require(
        :inspection_filter).permit(
          :scope, :definition, :description, :enable)
      inspection_filter = @inspection.inspection_filters.new(
        inspection_filter_params)

      if inspection_filter.save
        logger.debug("Filter '/#{filter[:scope]}/#{filter[:definition]}' " \
                     "for inspection #{@inspection.id} successfully created.")
      else
        logger.error("Unable to create filter " \
                     "'/#{filter[:scope]}/#{filter[:definition]}' for " \
                     "inspection #{@inspection.id}.")
      end
    end
  end

  # PUT /v1/machines/:machine_fqdn/inspections/:id/start
  def start_inspection
    # NOTE(gyee): delayed_job is tee'ing off on the start timestamp. We must
    # first clear it or otherwise the job is considered executed.
    @inspection.update(start: nil)

    @inspection.update(status: 'Scheduling analysis')
    @inspection.delay(queue: @inspection.id).inspect_scopes
    render status: :ok
  end 

  # DELETE /v1/machines/:machine_fqdn/inspections/:id
  def destroy
    @inspection.destroy
  end


  private

  # Use callbacks to share common setup or constraints between actions.
  def set_machine()
    @machine = Machine.find_by!(fqdn: params[:machine_fqdn])
  rescue ActiveRecord::RecordNotFound
    respond_to do |format|
      format.json { render json:
        { errors: "Machine '#{params[:machine_fqdn]}' not found." },
        status: :not_found }
    end
  end

  def set_inspection()
    @inspection = Inspection.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    respond_to do |format|
      format.json { render json:
        { errors: "Inspection '#{params[:id]}' not found." },
        status: :not_found }
    end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def inspection_params()
    params.require(:inspection).permit(
      :notes, scopes: []
    )
  end
end
