class AddSupportForDefaults < ActiveRecord::Migration
  def self.up
     add_column :users, :default_from, :integer
     add_column :users, :default_to, :integer
   end

   def self.down
     remove_column :users, :default_from
     remove_column :users, :default_to
   end
end
