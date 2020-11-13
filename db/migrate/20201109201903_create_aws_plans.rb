class CreateAwsPlans < ActiveRecord::Migration[5.1]
  def change
    create_table :aws_plans do |t|
      t.references :migrations_aws_vm, foreign_key: true, null: false
      t.references :inspection_export, foreign_key: true, null: false
      t.string :salt_minion
      t.integer :status
      t.string :notes
      t.string :description

      t.timestamps
    end
  end
end
