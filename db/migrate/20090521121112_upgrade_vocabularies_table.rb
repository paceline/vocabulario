class UpgradeVocabulariesTable < ActiveRecord::Migration 
  def self.up
    Vocabulary.find(:all).each do |v|
      if v.class.to_s == "Vocabulary"
        v.type = "Noun" unless v.gender == "N/A"
        v.save!
      end
    end
    say "Updated your vocabulary for use in a version 2.x vocabulario instance. Please note that you still have to wade through your verbs manually to deterine which is actually a verb and which is not."
  end

  def self.down
    execute "UPDATE vocabularies SET type=NULL WHERE type != 'Language'"
    say "Updated your vocabulary for use in a version 1.x vocabulario instance."
  end
end
