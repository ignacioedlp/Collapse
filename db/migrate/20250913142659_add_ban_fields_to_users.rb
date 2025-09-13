class AddBanFieldsToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :banned_at, :datetime
    add_column :users, :banned_reason, :text
    add_column :users, :banned_until, :datetime
    add_reference :users, :banned_by, null: true, foreign_key: { to_table: :admin_users }
    
    add_index :users, :banned_at
    add_index :users, :banned_until
  end
end
