class CreateVocabularies < ActiveRecord::Migration
  def self.up
    create_table :vocabularies do |t|
      t.references :user, :language
      t.string :type
      t.string :word
      t.string :gender, :limit => 10, :default => "N/A"
      t.string :permalink
      t.string :locale, :limit => 5
      t.timestamps
    end
    add_index :vocabularies, :permalink
  end

  def self.down
    drop_table :vocabularies
  end
end
