class CreateTranslations < ActiveRecord::Migration
  def self.up
    create_table :translations, :id => false do |t|
      t.integer :vocabulary1_id, :null => false
      t.integer :vocabulary2_id, :null => false
    end
    add_index :translations, :vocabulary1_id
    add_index :translations, :vocabulary2_id
  end

  def self.down
    drop_table :translations
  end
end
