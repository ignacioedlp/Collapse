class CreateUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :password_digest
      t.string :first_name
      t.string :last_name
      t.string :google_id
      t.string :provider
      t.datetime :confirmed_at

      t.timestamps
    end
    
    # Agregar índices para optimizar las consultas
    add_index :users, :email, unique: true
    add_index :users, :google_id
    add_index :users, :provider
  end
end
