class CreateMachines < ActiveRecord::Migration[5.1]
  def change
    create_table :machines do |t|
      t.string  :fqdn,                  null: false
      t.integer :port, default: 22,     null: false
      t.string  :nickname,              null: false
      t.text    :notes
      t.string  :user, default: 'root', null: false
      t.text    :key,                   null: false
      t.boolean :meets_prerequisites

      t.timestamps
    end
    add_index :machines, :fqdn, unique: true
  end
end
