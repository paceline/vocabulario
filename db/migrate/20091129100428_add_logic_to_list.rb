class AddLogicToList < ActiveRecord::Migration
  def self.up
    change_table(:lists) do |t|
      t.boolean :all_or_any
    end
    List.find(:all).each do |l|
      if l.all_or_any == nil && l.class.to_s == "DynamicList"
        l.all_or_any = false
        l.save!
      end
    end
  end

  def self.down
    change_table(:lists) do |t|
      t.remove :all_or_any
    end
  end
end
