class CreateInspections < ActiveRecord::Migration[5.1]
  def change
    create_table :inspections do |t|
      t.references :machine, foreign_key: true,   null: false
      t.text       :scopes,  default: [].to_yaml, null: false
      t.string     :description
      t.text       :notes
      t.datetime   :start
      t.string     :status

      t.timestamps
    end
  end
end
