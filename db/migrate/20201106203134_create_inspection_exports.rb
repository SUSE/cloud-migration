class CreateInspectionExports < ActiveRecord::Migration[5.1]
  def change
    create_table :inspection_exports do |t|
      t.references :inspection, foreign_key: true, null: false
      t.integer    :export_type, default: 0
      t.string     :unmanaged_files_excludes

      t.timestamps
    end
  end
end
