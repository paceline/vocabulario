class ListsController < ApplicationController
  
  # Filters
  before_filter :users_only, :except => [:index, :show]
  
  # Creates a new list
  def create
    type = params[:list].delete(:type) == 'true' ? 'DynamicList' : 'StaticList'
    tag_names = params[:list].delete(:tag_ids).collect { |t| Tag.find(t).name }.join(', ') unless type == 'StaticList'
    
    @list = Object.const_get(type).new(params[:list])
    @list.user = current_user
    @list.tag_list = tag_names unless type == 'StaticList'
    @list.save
    
    redirect_to list_path(@list.permalink)
  end
  
  # Deletes list from database
  def destroy
    @list = List.find(params[:id])
    @list.destroy
    flash[:notice] = "You wanted it. List has been deleted from to the database."
    redirect_to lists_path
  end
  
  # Edit list
  def edit
    begin
      @list = List.find_by_permalink(params[:id])
    rescue
      render :file => "#{RAILS_ROOT}/public/404.html", :status => 404
    end
  end
  
  # List all list (dynamic and static)
  def index
    redirect_to community_path
  end
  
  # Add a new list
  def new
    begin
      @user = current_user
      @list = List.new
    rescue
      render :file => "#{RAILS_ROOT}/public/404.html", :status => 404
    end
  end
  
  # Adds new item to a static list
  def newitem
    list = List.find(params[:id])
    position = params.key?(:insert_after) ? list.ids.index(params[:insert_after])+2 : 1
    vocabulary = Vocabulary.find(params[:vocabulary_id])
    vocabulary = vocabulary.translations(list.language_from_id).first if list.language_to == vocabulary.language
    @lister = list.vocabulary_lists.build({ :vocabulary_id => vocabulary.id })
    if @lister.valid? && @lister.errors.empty?
      @lister.save
      @lister.insert_at(position)
      render :update do |page|
        page.hide :dropzone if list.size <= 1
        page.replace_html 'static_list', render(:partial => 'advanced_list', :object => list)
        page.visual_effect :shake, "list_item_#{vocabulary.id}"
      end
    else
      render :nothing => true
    end
  end
  
  # Reorder a static list
  def reorder
    @list = List.find(params[:id]) 
    @list.vocabulary_lists.each do |t| 
      t.position = params['static_list'].index(t.vocabulary_id.to_s) + 1
      t.save 
    end 
    render :nothing => true
  end
  
  # Shows list
  def show
    begin
      @list = List.find_by_permalink(params[:id])
      if @list.public || @list.user == current_user
        @vocabularies = @list.vocabularies
        respond_to do |format|
          format.html { render :action => 'show' }
          format.json { render :json => @vocabularies.to_json(:except => [ :user_id, :language_id, :permalink, :created_at, :updated_at ], :include => [ :language, :translation_to ]) }
          format.xml { render :xml => @vocabularies.to_xml(:except => [ :user_id, :language_id, :permalink, :created_at, :updated_at ], :include => [ :language, :translation_to ]) }
        end
      else
        redirect_to '/login'
      end
    rescue
      render :file => "#{RAILS_ROOT}/public/404.html", :status => 404
    end
  end
  
  # Live search of the vocabularies database
  def live
    list = List.find(params[:id])
    @search = params[:word]
    @vocabularies = Vocabulary.find(:all, :conditions => ['(language_id = ? OR language_id = ?) AND word LIKE ?', list.language_from.id, list.language_to.id, "%#{params[:word]}%"], :limit => 10, :order => 'word') if params[:word].size >= 3
    render :nothing => true if @vocabularies.blank?
  end
  
  # /lists/new support: Hide tags menu when static is selected (and vice versa)
  def switch
    render :update do |page|
      if params[:selected] == 'false'
        page.hide 'list_tag_ids'
        page << "$('list_tags_input').childElements().last().update('Tags only work with dynamic lists')"
        page << "new Effect.Highlight('list_tags_input')"
      else
        page.show 'list_tag_ids'
        page << "$('list_tags_input').childElements().last().update('Select some tags to narrow down the word selection')"
        page << "new Effect.Highlight('list_tags_input')"
      end
    end
  end
  
  # Update vocabulary list
  def update
    @list = List.find(params[:id])

    if @list.class.to_s == 'StaticList'
      @list.update_attributes(params[:static_list])
    else
      tag_names = params[:dynamic_list].delete(:tag_ids).collect { |t| Tag.find(t).name }.join(', ') 
      @list.tag_list = tag_names
      @list.update_attributes(params[:dynamic_list])
    end
    
    redirect_to list_path(@list.permalink)
  end
  
  # Remove vocabulary from list
  def unlink
    list = VocabularyList.find(:first, :conditions => ['list_id = ? AND vocabulary_id = ?', params[:id], params[:vocabulary_id]])
    list.remove_from_list
    list.destroy
    render :update do |page|
      page.visual_effect :drop_out, "list_item_#{params[:vocabulary_id]}"
    end
  end
  
end
