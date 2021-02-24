class MigrationsAwsVm < ApplicationRecord
  has_many  :aws_plans, :dependent => :destroy

  validates :region, presence: true
  validates :image_id, presence: true
  validates :instance_type, presence: true

  def create_aws_vm
    puts "Creating"
    aws = AWSProvider.new
    aws.instance_name = instance_name
    aws.region = region
    aws.image_id = image_id 
    aws.instance_type = instance_type 
    aws.key_name = key_name 
    aws.availability_zone = availability_zone 
    aws.iam_role = iam_role 
    aws.secret_file_path = File.join(File.dirname(__FILE__), 'config.json') 
    aws.create_instance
    self.instance_id = aws.instance_id
    self.salt_minion = aws.salt_minion
    self.instance_name = aws.instance_name
  end

  # Enables routing on instance_id instead of id for generated routes
  def to_param
    self.instance_id
  end

  def stop_instance
    aws = AWSProvider.new
    aws.secret_file_path = File.join(File.dirname(__FILE__), 'config.json')
    aws.region = self.region
    aws.instance_id = self.instance_id
    aws.stop_instance
  end

  def start_instance
    aws = AWSProvider.new
    aws.secret_file_path = File.join(File.dirname(__FILE__), 'config.json')
    aws.region = self.region
    aws.instance_id = self.instance_id
    aws.start_instance
  end

  def terminate_instance
    aws = AWSProvider.new
    aws.secret_file_path = File.join(File.dirname(__FILE__), 'config.json')
    aws.region = self.region
    aws.instance_id = self.instance_id
    aws.terminate_instance
  end

end
