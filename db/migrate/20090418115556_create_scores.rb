class CreateScores < ActiveRecord::Migration
  def self.up
    create_table :scores do |t|
      t.references :user, :language
      t.integer :points, :default => 0
      t.integer :questions
      t.timestamps
    end
  end

  def self.down
    drop_table :scores
  end
end
