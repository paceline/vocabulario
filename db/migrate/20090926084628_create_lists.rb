class CreateLists < ActiveRecord::Migration
  def self.up
    create_table :lists do |t|
      t.references :user, :language_from, :language_to
      t.string :type, :limit => 25
      t.string :name
      t.string :permalink
      t.boolean :public, :default => true
      t.timestamps
    end
  end

  def self.down
    drop_table :lists
  end
end
