class ExtendListTypes < ActiveRecord::Migration
  def self.up
    execute "UPDATE lists SET type='SmartVocabularyList' WHERE type='DynamicList'"
    execute "UPDATE lists SET type='StaticVocabularyList' WHERE type='StaticList'"
  end
  
  def self.down
    execute "UPDATE lists SET type='DynamicList' WHERE type LIKE 'Smart%List'"
    execute "UPDATE lists SET type='StaticList' WHERE type LIKE 'Static%List'"
  end
end
