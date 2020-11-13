class V1::MachinesController < ApplicationController
  before_action :set_machine, only: [:show, :edit, :update, :destroy]

  # GET /v1/machines
  def index
    @machines = Machine.all
    respond_to do |format|
      format.json { render json: @machines, status: :ok }
    end
  end

  # GET /v1/machines/{fqdn}
  def show
    respond_to do |format|
      format.json { render json: @machine, status: :ok }
    end
  end

  # POST /v1/machines
  def create
    @machine = Machine.new(machine_params)

    respond_to do |format|
      if @machine.save
        format.json { render json: @machine, status: :created }
      else
        format.json { render json: { errors: @machine.errors.full_messages },
                      status: :unprocessable_entity }
      end
    end
  end

  # PUT /v1/machines/{fqdn}
  def update
    respond_to do |format|
      if @machine.update(machine_params)
        format.json { render json: @machine, status: :created }
      else
        format.json { render json: { errors: @machine.errors.full_messages },
                      status: :unprocessable_entity }
      end
    end
  end

  # DELETE /v1/machines/{machinename}
  def destroy
    @machine.destroy
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_machine
      @machine = Machine.find_by!(fqdn: params[:fqdn])
    rescue ActiveRecord::RecordNotFound
      respond_to do |format|
        format.json { render json: 
          { errors: "Machine '#{params[:fqdn]}' not found." },
          status: :not_found }
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def machine_params
      params.require(:machine).permit(
        :fqdn, :port, :nickname, :notes, :user, :key
      )
    end
end
