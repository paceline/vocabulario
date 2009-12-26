class ListsController < ApplicationController
  
  # Filters
  before_filter :browser_required, :except => [:index, :show]
  before_filter :login_required, :except => [:index, :print, :show, :sort]
  
  # Creates a new list
  def create
    type = params[:list].delete(:type) == 'true' ? 'DynamicList' : 'StaticList'
    tag_names = params[:list].delete(:tag_ids).collect { |t| Tag.find(t).name }.join(', ') unless params[:list][:tag_ids].blank?
    @list = Object.const_get(type).new(params[:list])
    @list.user = current_user
    @list.tag_list = tag_names unless params[:list][:tag_ids].blank?
    if @list.valid? && @list.errors.empty?
      @list.save
      redirect_to list_path(@list.permalink)
    else
      render :new
    end
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
      @list = List.find_by_id_or_permalink(params[:id])
    rescue
      render :file => "#{RAILS_ROOT}/public/404.html", :status => 404
    end
  end
  
  # List all list (dynamic and static)
  #
  # API information - 
  #   /lists.xml|json (No oauth required)
  #   /users/#{id|permalink}/lists.xml|json (Oauth required)
  def index
    @lists = params.key?(:user_id) && current_user && (params[:user_id].to_i == current_user.id || params[:user_id] == current_user.permalink) ? current_user.lists : List.find_public(current_user)
    respond_to do |format|
      format.html { redirect_to community_path }
      format.json { render :json => current_user ? @lists.to_json(:except => [:all_or_any, :language_from_id, :language_to_id, :time_unit, :time_value, :confirmation_token, :encrypted_password, :email, :email_confirmed, :remember_token, :salt, :user_id], :include => [:language_from, :language_to, :user]) : @lists.to_json(:except => [:all_or_any, :language_from_id, :language_to_id, :time_unit, :time_value, :user_id], :include => [:language_from, :language_to]) }
      format.xml { render :xml => current_user ? @lists.to_xml(:except => [:all_or_any, :language_from_id, :language_to_id, :time_unit, :time_value, :confirmation_token, :encrypted_password, :email, :email_confirmed, :remember_token, :salt, :user_id], :include => [:language_from, :language_to, :user]) : @lists.to_xml(:except => [:all_or_any, :language_from_id, :language_to_id, :time_unit, :time_value, :user_id], :include => [:language_from, :language_to]) }
    end
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
  
  # Moves or copies vocabulary from one list to another
  def copy_move
    if params.key?(:new_list_id)
      vocabulary = Vocabulary.find(params[:vocabulary_id])
      vocabulary.remove_from_list(params[:id]) if params[:commit] == 'Move to list'
      vocabulary.add_to_list(params[:new_list_id])
      render(:update) { |page| params[:commit] == 'Move to list' ? page.visual_effect(:drop_out, "list_item_#{params[:vocabulary_id]}") : page << "toggleListMenu('#{params[:vocabulary_id]}')" }
    else
      @params = params
      @list = List.find(params[:id])
      @lists = StaticList.list("id != #{@list.id}")
      render :partial => 'copy_move_form'
    end
  end
  
  # Adds new item to a static list
  def newitem
    @list = List.find(params[:id])
    position = params.key?(:insert_after) ? @list.ids.index(params[:insert_after])+2 : 1
    vocabulary = Vocabulary.find(params[:vocabulary_id])
    vocabulary = vocabulary.translations(list.language_from_id).first if @list.language_to == vocabulary.language
    valid = vocabulary.add_to_list(@list.id, position)
    if valid
      render :update do |page|
        page.hide :dropzone if @list.size <= 1
        page.replace_html 'static_list', render(:partial => 'admin_list')
        page.visual_effect :shake, "list_item_#{vocabulary.id}"
      end
    else
      render :nothing => true
    end
  end
  
  # Render show view for printing
  def print
   begin
      @list = List.find_by_id_or_permalink(params[:id])
      if @list.public || @list.user == current_user
        @vocabularies = @list.vocabularies
        render :layout => 'print'
      else
        redirect_to '/login'
      end
    rescue
      render :file => "#{RAILS_ROOT}/public/404.html", :status => 404
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
  #
  # API information - 
  #   /lists/#{id|permalink}.xml|json (No oauth required, if public)
  def show
    begin
      @list = List.find_by_id_or_permalink(params[:id])
      if @list.public || @list.user == current_user
        @vocabularies = @list.vocabularies
        respond_to do |format|
          format.html
          format.atom { render :layout => false }
          format.json { render :json => current_user ? @list.to_json(:except => [:all_or_any, :language_id, :language_from_id, :language_to_id, :time_unit, :time_value, :confirmation_token, :encrypted_password, :email, :email_confirmed, :remember_token, :salt, :user_id], :include => [:language_from, :language_to, :user, :vocabularies]) : @list.to_json(:except => [:all_or_any, :language_id, :language_from_id, :language_to_id, :time_unit, :time_value, :confirmation_token, :encrypted_password, :email, :email_confirmed, :remember_token, :salt, :user_id], :include => [:language_from, :language_to, :vocabularies]) }
          format.xml { render :xml => current_user ? @list.to_xml(:except => [:all_or_any, :language_id, :language_from_id, :language_to_id, :time_unit, :time_value, :confirmation_token, :encrypted_password, :email, :email_confirmed, :remember_token, :salt, :user_id], :include => [:language_from, :language_to, :user, :vocabularies]) : @list.to_xml(:except => [:all_or_any, :language_id, :language_from_id, :language_to_id, :time_unit, :time_value, :confirmation_token, :encrypted_password, :email, :email_confirmed, :remember_token, :salt, :user_id], :include => [:language_from, :language_to, :vocabularies]) }
        end
      else
        respond_to do |format|
          format.html || format.atom { redirect_to '/login' }
          format.json || format.xml { render :nothing => true, :status => 401 }
        end
      end
    rescue
      render :file => "#{RAILS_ROOT}/public/404.html", :status => 404
    end
  end
  
  # Sort a dynamic list by different attributes
  def sort
    if params.key?(:attribute) && params.key?(:order)
      @list = List.find(params[:id])
      @vocabularies = @list.vocabularies(params[:attribute], params[:order])
      render :partial => 'regular_list'
    else
      render :nothing => true
    end
  end
  
  # Live search of the vocabularies database
  def live
    list = List.find(params[:id])
    @search = params[:word]
    @vocabularies = Vocabulary.find(:all, :conditions => ['(language_id = ? OR language_id = ?) AND word LIKE ?', list.language_from.id, list.language_to.id, "%#{params[:word]}%"], :limit => 10, :order => 'word') if params[:word].size >= 3
    render :nothing => true if @vocabularies.blank?
  end
  
  # Update vocabulary list
  def update
    @list = List.find_by_id_or_permalink(params[:id])

    if @list.static?
      @list.update_attributes(params[:static_list])
    else
      if params[:dynamic_list][:tag_ids]
        tag_names = params[:dynamic_list].delete(:tag_ids).collect { |t| Tag.find(t).name }.join(', ')
        @list.tag_list = tag_names
      end
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
  
  # /lists/show support: Show options menu
  def show_options_menu
    @list = List.find(params[:id])
    @vocabulary = Vocabulary.find(params[:vocabulary_id])
    render :update do |page|
      page.replace_html "options_for_#{@vocabulary.id}", render(:partial => 'options_menu')
      page << "toggleListMenu('#{@vocabulary.id}')"
    end
  end
  
  # /lists/new support: Hide tags menu when static is selected (and vice versa)
  def switch
    render :update do |page|
      if params[:selected] == 'false'
        page.hide 'list_tags_input', 'list_time_input'
      else
        page.show 'list_tags_input', 'list_time_input'
        page.visual_effect :highlight, 'list_tags_input'
        page.visual_effect :highlight, 'list_time_input'
      end
    end
  end
  
end
