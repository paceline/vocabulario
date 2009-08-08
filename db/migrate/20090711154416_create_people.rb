class CreatePeople < ActiveRecord::Migration
  def self.up
    create_table :people do |t|
      t.references :language
      t.string :first_person_singular, :limit => 50
      t.string :second_person_singular, :limit => 50
      t.string :third_person_singular, :limit => 50
      t.string :first_person_plural, :limit => 50
      t.string :second_person_plural, :limit => 50
      t.string :third_person_plural, :limit => 50
      t.string :pronoun, :limit => 50
      t.timestamps
    end
  end

  def self.down
    drop_table :people
  end
end
