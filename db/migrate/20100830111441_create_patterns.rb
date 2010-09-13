class CreatePatterns < ActiveRecord::Migration
  def self.up
    create_table :patterns do |t|
      t.references :conjugation_time
      t.string :name
      t.integer :person
    end
    create_table :patterns_verbs, :id => false do |t|
      t.references :pattern
      t.references :verb
    end
  end
  
  def self.down
    drop_table :patterns
    drop_table :patterns_verbs
  end
end
