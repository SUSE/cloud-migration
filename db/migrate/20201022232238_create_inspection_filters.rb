class CreateInspectionFilters < ActiveRecord::Migration[5.1]
  def change
    create_table :inspection_filters do |t|
      t.references :inspection, foreign_key: true, null: false
      t.string     :scope,                         null: false
      t.string     :definition,                    null: false
      t.boolean    :enable,     default: true
      t.string     :description

      t.timestamps
    end
  end
end
