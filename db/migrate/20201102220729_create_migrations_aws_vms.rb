class CreateMigrationsAwsVms < ActiveRecord::Migration[5.1]
  def change
    create_table :migrations_aws_vms do |t|
      t.string :instance_id
      t.string :region
      t.string :image_id
      t.string :instance_type
      t.string :key_name
      t.string :subnet_id
      t.string :security_id
      t.string :availability_zone
      t.string :vpc_id
      t.string :iam_role
      t.string :salt_minion

      t.timestamps
    end
  end
end
