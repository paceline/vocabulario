class CreateRules < ActiveRecord::Migration
  def self.up
    create_table :rules do |t|
      t.string :name
      t.string :find
      t.string :replace
    end
  end

  def self.down
    drop_table :rules
  end
end
