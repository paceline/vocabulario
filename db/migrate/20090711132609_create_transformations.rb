class CreateTransformations < ActiveRecord::Migration
  def self.up
    create_table :transformations do |t|
      t.string :type, :limit => 50
      t.references :vocabulary
      t.integer :position
      t.integer :pattern_start
      t.integer :pattern_end
      t.integer :insert_before
      t.boolean :include_white_space, :default => 0
      t.timestamps
    end
  end

  def self.down
    drop_table :transformations
  end
end
