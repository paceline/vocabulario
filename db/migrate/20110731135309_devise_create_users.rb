class DeviseCreateUsers < ActiveRecord::Migration
  def self.up
    create_table(:users) do |t|
      t.string :name
      t.string :permalink
      t.integer :default_from
      t.integer :default_to
      t.database_authenticatable :null => false
      t.recoverable
      t.rememberable
      t.trackable
      # t.encryptable
      # t.confirmable
      # t.lockable :lock_strategy => :failed_attempts, :unlock_strategy => :both
      # t.token_authenticatable
      t.boolean :admin, :default => false
      t.timestamps
    end
    add_index :users, :email,                :unique => true
    add_index :users, :reset_password_token, :unique => true
    # add_index :newusers, :confirmation_token,   :unique => true
    # add_index :newusers, :unlock_token,         :unique => true
    # add_index :newusers, :authentication_token, :unique => true
  end

  def self.down
    drop_table :users
  end
end
