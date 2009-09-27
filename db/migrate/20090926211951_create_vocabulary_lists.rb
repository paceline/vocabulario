class CreateVocabularyLists < ActiveRecord::Migration
  def self.up
    create_table :vocabulary_lists do |t|
      t.references :list, :vocabulary
      t.integer :position
    end
  end

  def self.down
    drop_table :vocabulary_lists
  end
end
