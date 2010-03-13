class CreateComments < ActiveRecord::Migration
  
  def self.up
    # Create table
    create_table :comments do |t|
      t.references :user, :commentable
      t.string :commentable_type
      t.string :text
      t.timestamps
    end
    
    # Import comments from vocabularies
    Vocabulary.find(:all).each do |v|
      v.comments.create({ :text => v.comment }) unless v.comment.blank? || v.comment == '-'
    end
    
    # Remove comment column
    remove_column :vocabularies, :comment
  end


  def self.down
    # Add comment column
    add_column :vocabularies, :comment, :string
    
    # Re-import comments into vocabularies
    execute "UPDATE vocabularies SET comment='-'"
    Comment.find(:all, :conditions => "commentable_type = 'Vocabulary'").each do |c|
      v = c.commentable
      v.comment = c.text
      v.save
    end
    
    # Drop table
    drop_table :comments
  end
end
