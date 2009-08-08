class CreateConjugationTimes < ActiveRecord::Migration
  def self.up
     create_table :conjugation_times do |t|
       t.references :language
       t.string :name, :limit => 25
       t.timestamps
     end
   end

   def self.down
     drop_table :conjugation_times
   end
end