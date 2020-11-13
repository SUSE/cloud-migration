class V1::InspectionFiltersController < ApplicationController
  before_action :set_inspection, only: [:new, :create]
  before_action :set_inspection_filter, only: [:show, :edit, :update, :destroy]

  # GET /v1/machines/:machine_fqdn/inspections/:inspection_id/filters
  def index
    @inspection_filters = InspectionFilter.all
    respond_to do |format|
      format.json { render json: @inspection_filters,
                    fqdn: params[:machine_fqdn], status: :ok }
    end
  end

  # GET /v1/machines/:machine_fqdn/inspections/:inspection_id/filters/:id
  def show
    respond_to do |format|
      format.json { render json: @inspection_filter,
                    fqdn: params[:machine_fqdn], status: :ok }
    end
  end

  # POST /v1/machines/:machine_fqdn/inspections/:inspection_id/filters
  def create
    @inspection_filter = @inspection.inspection_filters.new(
      inspection_filter_params)

    respond_to do |format|
      if @inspection_filter.save
        format.json { render json: @inspection_filter, status: :created }
      else
        format.json { render json: {
          errors: @inspection_filter.errors.full_messages },
          status: :unprocessable_entity }
      end
    end
  end

  # PUT /v1/machines/:machine_fqdn/inspections/:inspection_id/filters/:id
  def update
    respond_to do |format|
      unless @inspection_filter.update(inspection_filter_params)
        format.json { render json: {
          errors: @inspection_filter.errors.full_messages },
          status: :unprocessable_entity }
      end
    end
  end

  # DELETE /v1/machines/:machine_fqdn/inspections/:inspection_id/filters/:id
  def destroy
    @inspection_filter.destroy
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
    def set_inspection_filter
      @inspection_filter = InspectionFilter.find_by!(params[:id])
    rescue ActiveRecord::RecordNotFound
      respond_to do |format|
        format.json { render json:
          { errors: "Inspection filter '#{params[:id]}' not found." },
          status: :not_found }
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def inspection_filter_params
      params.require(:inspection_filter).permit(
        :scope, :definition, :description, :enable
      )
    end
end
