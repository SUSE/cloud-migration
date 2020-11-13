class V1::Migrations::Aws::PlansController < ApplicationController
  before_action :set_aws_plan,          only: [:show, :destroy, :update,
                                               :update, :show]
  #before_action :set_inspection_export, only: [:new, :create]
  before_action :set_aws_vm,            only: [:new, :create]

  # POST /v1/migrations/aws/vms/:instance_id/plans
  def create
    @aws_plan = @aws_vm.aws_plans.new(aws_plan_params)
    #salt_minion = params[:aws_plan].fetch(:salt_minion, nil)
    respond_to do |format|
      if @aws_plan.save
        @aws_plan.update(status: :migration_scheduled)
        @aws_plan.delay(queue: @aws_plan.id).execute_plan
        format.json { render json: @aws_plan, instance_id: params[:instance_id],
                      status: :created }
      else
        format.json { render json: { errors: @aws_plan.errors },
                      status: :unprocessable_entity }
      end
    end
  end

  # GET /v1/migrations/aws/vms/:instance_id/plans
  def index
    @aws_plans = AwsPlan.all
    respond_to do |format|
      format.json { render json: @aws_plans,
                    instance_id: params[:instance_id], status: :ok }
    end
  end

  # GET /v1/migrations/aws/vms/:instance_id/plans/:id
  def show
    respond_to do |format|
      format.json { render json: @aws_plan,
                    instance_id: params[:instance_id], status: :ok }
    end
  end

  # TODO(gyee): should we support PUT operation, where we re-apply the Salt
  # states?

  # DELETE /v1/migrations/aws/vms/:instance_id/plans/:id
  def destroy
    @aws_plan.destroy
  end

  private

  def set_aws_plan()
    @aws_plan = AwsPlan.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    respond_to do |format|
      format.json { render json:
        { errors: "AWS plan '#{params[:id]}' not found." },
        status: :not_found }
    end
  end

  def set_aws_vm()
    @aws_vm = MigrationsAwsVm.find_by!(instance_id: params[:vm_instance_id])
  rescue ActiveRecord::RecordNotFound
    respond_to do |format|
      format.json { render json:
        { errors: "AWS instance '#{params[:vm_instance_id]}' not found." },
        status: :not_found }
    end
  end

  def set_inspection_export()
    @inspection_export = InspectionExport.find(
      params[:aws_plan][:inspection_export_id])
  rescue ActiveRecord::RecordNotFound
    respond_to do |format|
      format.json { render json:
        { errors: "Inspection export " \
                  "'#{params[:aws_plan][:inspection_export_id]}' not found." },
        status: :not_found }
    end
  end

  def aws_plan_params()
    params.require(:aws_plan).permit(
      :inspection_export_id, :description, :salt_minion
    )
  end
end
