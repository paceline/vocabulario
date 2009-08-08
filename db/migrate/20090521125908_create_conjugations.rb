class CreateConjugations < ActiveRecord::Migration
  def self.up
    create_table :conjugations do |t|
      t.references :conjugation_time
      t.string :name, :limit => 25
      t.boolean :regular, :default => true
      t.string :first_person_singular, :limit => 50
      t.string :second_person_singular, :limit => 50
      t.string :third_person_singular, :limit => 50
      t.string :first_person_plural, :limit => 50
      t.string :second_person_plural, :limit => 50
      t.string :third_person_plural, :limit => 50
      t.timestamps
    end
    create_table :conjugations_verbs, :id => false do |t|
      t.integer :conjugation_id
      t.integer :verb_id
    end
    add_column :scores, :test_type, :string, :limit => 50
    execute "UPDATE scores SET test_type='VocabularyTest'"
  end

  def self.down
    drop_table :conjugations
    drop_table :conjugations_verbs
    remove_column :scores, :test_type
  end
end