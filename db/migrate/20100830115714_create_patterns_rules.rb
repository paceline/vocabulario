class CreatePatternsRules < ActiveRecord::Migration
  def self.up
    create_table :patterns_rules do |t|
      t.references :pattern
      t.references :rule
      t.integer :position
    end
  end

  def self.down
    drop_table :patterns_rules
  end
end
