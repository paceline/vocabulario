class ExtendVocabularies < ActiveRecord::Migration
  def self.up
    add_column :vocabularies, :comment, :string, :default => '-'
    execute "UPDATE vocabularies SET comment='-'"
  end

  def self.down
    remove_column :vocabularies, :comment
  end
end
