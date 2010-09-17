class CreateVocabularyLists < ActiveRecord::Migration
  def self.up
    create_table :vocabulary_lists do |t|
      t.references :list, :vocabulary
      t.integer :position
    end
    add_index :vocabulary_lists, :list_id
    add_index :vocabulary_lists, :vocabulary_id
  end

  def self.down
    drop_table :vocabulary_lists
  end
end
