class LinkMultipleLanguagesToScore < ActiveRecord::Migration
  def self.up
    rename_column :scores, :language_id, :language_from_id
    add_column :scores, :language_to_id, :integer
  end

  def self.down
    rename_column :scores, :language_from_id, :language_id
    remove_column :scores, :language_to_id
  end
end
