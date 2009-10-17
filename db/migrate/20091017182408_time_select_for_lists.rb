class TimeSelectForLists < ActiveRecord::Migration
  def self.up
    change_table(:lists) do |t|
      t.integer :time_value
      t.string :time_unit, :limit => 10
    end
  end

  def self.down
    change_table(:lists) do |t|
      t.remove :time_value
      t.remove :time_unit
    end
  end
end
