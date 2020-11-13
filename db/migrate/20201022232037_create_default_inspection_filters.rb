class CreateDefaultInspectionFilters < ActiveRecord::Migration[5.1]
  def change
    create_table :default_inspection_filters do |t|
      t.string  :scope,                     null: false
      t.string  :definition,                null: false
      t.boolean :enable,     default: true
      t.string  :description

      t.timestamps
    end
  end
end
