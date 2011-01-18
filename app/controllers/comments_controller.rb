class CommentsController < ApplicationController
  
  # Layout
  layout nil
  
  # Filters
  before_filter :browser_required
  
  # Create a new comment
  def create
    if params.key?(:commentable_id) && params.key?(:commentable_type)
      object = Object.const_get(params[:commentable_type]).find(params[:commentable_id])
      comment = object.comments.create({ :text => params[:comment][:text], :user_id => current_user.id })
      comment.save
      render :update do |page|
        page.hide 'blank'
        page.insert_html :bottom, params[:update], render(comment)
        page << "new Effect.Highlight('#{comment.commentable_type.downcase}_comment_#{comment.id}')"
        page << "$('comment_text').value = ''"
        page << "enableHiddenOptions('.strong','.delete');"
      end
    end
  end
  
  # Delete a comment
  def destroy
    comment = Comment.find(params[:id])
    empty = comment.commentable.comments.count <= 1
    dom_id = "#{comment.commentable_type.downcase}_comment_#{comment.id}"
    comment.destroy
    render :update do |page|
      page << "new Effect.DropOut(#{dom_id})"
      page.show 'blank' if empty
    end
  end
  
end
