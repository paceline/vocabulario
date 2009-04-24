class CreateTranslations < ActiveRecord::Migration
  def self.up
    create_table :translations, :id => false do |t|
      t.integer :vocabulary1_id, :null => false
      t.integer :vocabulary2_id, :null => false
      t.add_index [:vocabulary1_id, :vocabulary2_id], :unique => true
    end
  end

  def self.down
    drop_table :translations
  end
end
