class V1::Defaults::Inspection::FiltersController < ApplicationController
  before_action :set_inspection_filter, only: [:show, :edit, :update, :destroy]

  def index
    @inspection_filters = DefaultInspectionFilter.all
    render json: @inspection_filters, status: :ok
  end

  def show
    render json: @inspection_filter, status: :ok
  end

  def create
    @inspection_filter = DefaultInspectionFilter.new(inspection_filter_params)
    if @inspection_filter.save
      render json: @inspection_filter, status: :created
    else
      render json: { errors: @inspection_filter.errors.full_messages },
             status: :unprocessable_entity
    end
  end

  def update
    unless @inspection_filter.update(inspection_filter_params)
      render json: { errors: @inspection_filter.errors.full_messages },
             status: :unprocessable_entity
    end
  end

  def destroy
    @inspection_filter.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_inspection_filter
      @inspection_filter = DefaultInspectionFilter.find_by!(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def inspection_filter_params
      params.require(:inspection_filter).permit(
        :scope, :definition, :description, :enable
      )
    end
end
