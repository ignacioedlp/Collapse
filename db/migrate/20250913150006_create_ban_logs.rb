class CreateBanLogs < ActiveRecord::Migration[7.2]
  def change
    create_table :ban_logs do |t|
      t.references :user, null: false, foreign_key: true
      t.references :admin_user, null: false, foreign_key: true
      t.string :action, null: false # 'banned', 'unbanned', 'auto_banned'
      t.text :reason
      t.datetime :banned_until
      t.string :ip_address
      
      t.timestamps
    end
    
    add_index :ban_logs, :created_at
    add_index :ban_logs, [:user_id, :created_at]
    add_index :ban_logs, :action
  end
end
