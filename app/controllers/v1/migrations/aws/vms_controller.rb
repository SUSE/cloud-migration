class V1::Migrations::Aws::VmsController < ApplicationController
  before_action :set_migrations_aws_vms, only: [:show, :edit, :stop_instance, :start_instance, :terminate_instance]
 
  def index
    @aws_vms = MigrationsAwsVm.all
    render json: @aws_vms, status: :ok
  end

  def show
    render json: @aws_vm, status: :ok
  end

  def create
    @aws_vms = MigrationsAwsVm.new(awsvms_params)
    logger.debug("Creating AWS VM")
    @aws_vms.create_aws_vm
    if @aws_vms.save
      render json: @aws_vms, status: :created
    else
      render json: { errors: @aws_vms.errors.full_messages },
             status: :unprocessable_entity
    end
  end

  def stop_instance
    @aws_vm.stop_instance
    render status: :ok
  end

  def start_instance
    @aws_vm.start_instance
    render status: :ok
  end

  def terminate_instance
    @aws_vm.terminate_instance
    @aws_vm.destroy
    render status: :ok
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_migrations_aws_vms
      @aws_vm = MigrationsAwsVm.find_by!(instance_id: params[:instance_id])
    rescue ActiveRecord::RecordNotFound
      respond_to do |format|
        format.json { render json:
          { errors: "Instance '#{params[:instance_id]}' not found." },
          status: :not_found }
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def awsvms_params
      params.require(:migrations_aws_vm).permit(
        :region, :image_id, :instance_type, :key_name, :availability_zone, :iam_role, :security_id, :subnet_id, :vpc_id
      )
    end
end
