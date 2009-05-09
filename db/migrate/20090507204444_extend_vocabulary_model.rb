class ExtendVocabularyModel < ActiveRecord::Migration
  def self.up
    remove_column :vocabularies, :language
    add_column :vocabularies, :type, :string, :limit => 25
  end

  def self.down
    add_column :vocabularies, :language, :boolean, :default => false
    remove_column :vocabularies, :type
  end
end
