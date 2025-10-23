class CreateReports < ActiveRecord::Migration[7.2]
  def change
    create_table :reports do |t|
      t.references :reported_user, null: false, foreign_key: { to_table: :users }
      t.references :reporter, null: false, foreign_key: { to_table: :users }
      t.string :reason, null: false # 'spam', 'harassment', 'inappropriate_content', 'other'
      t.text :description, null: false
      t.string :status, default: 'pending' # 'pending', 'reviewed', 'resolved', 'dismissed'
      t.string :ip_address
      t.references :reviewed_by, null: true, foreign_key: { to_table: :admin_users }
      t.text :admin_notes
      
      t.timestamps
    end
    
    add_index :reports, :created_at
    add_index :reports, [:reported_user_id, :created_at]
    add_index :reports, :status
    add_index :reports, :reason
  end
end
