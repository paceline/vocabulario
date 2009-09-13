class ClearanceUpdateUsers < ActiveRecord::Migration
  def self.up
    change_table(:users) do |t|
      t.remove :login, :crypted_password, :remember_token_expires_at, :activation_code, :activated_at, :state, :deleted_at
      t.string :permalink, :limit => 128
      t.string :encrypted_password, :limit => 128
      t.string :confirmation_token, :limit => 128
      t.boolean :email_confirmed, :default => false, :null => false
    end

    add_index :users, [:id, :confirmation_token]
    add_index :users, :email
    add_index :users, :remember_token
  end

  def self.down
    change_table(:users) do |t|
      t.string :login, :limit => 40
      t.string :crypted_password, :limit => 40
      t.datetime :remember_token_expires_at
      t.string :activation_code, :limit => 40
      t.datetime :activated_at
      t.string :state, :null => :no, :default => 'passive'
      t.datetime :deleted_at, :datetime
      t.remove :permalink, :encrypted_password, :confirmation_token, :email_confirmed
    end
  end
end
