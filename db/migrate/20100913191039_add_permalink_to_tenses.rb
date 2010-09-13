class AddPermalinkToTenses < ActiveRecord::Migration
  def self.up
    add_column :conjugation_times, :permalink, :string
    ConjugationTime.find(:all).each(&:save)
  end

  def self.down
    remove_column :conjugation_times, :permalink
  end
end
