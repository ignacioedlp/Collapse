class CreateRoles < ActiveRecord::Migration[7.2]
  def change
    create_table :roles do |t|
      t.string :name, null: false
      t.string :resource_type
      t.bigint :resource_id
      t.timestamps
    end

    create_table :users_roles, id: false do |t|
      t.references :user, null: false, foreign_key: true
      t.references :role, null: false, foreign_key: true
    end
    
    add_index :roles, :name, unique: true
    add_index :roles, [:name, :resource_type, :resource_id]
    add_index :users_roles, [:user_id, :role_id], unique: true
  end
end
