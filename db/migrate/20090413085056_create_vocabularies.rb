class CreateVocabularies < ActiveRecord::Migration
  def self.up
    create_table :vocabularies do |t|
      t.references :user, :language
      t.string :word
      t.string :gender, :limit => 10, :default => "N/A"
      t.boolean :language, :default => 0
      t.string :permalink
      t.timestamps
    end
    add_index :vocabularies, :permalink
  end

  def self.down
    drop_table :vocabularies
  end
end
