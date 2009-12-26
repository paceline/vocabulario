class TransformationsController < ApplicationController
  
  # Layout
  layout nil
  
  # Filters
  before_filter :login_required
  
  # Creates new transformation
  def create
    @vocabulary = Vocabulary.find(params[:vocabulary_id])
    if @vocabulary
      @transformation = Object::const_get(params[:type]).new
      @transformation.vocabulary = @vocabulary
      @transformation.insert_at(@vocabulary.transformations.size+1)
      @transformation.save
      render :update do |page|
        page.insert_html :bottom, 'transformation-list', render(:partial => 'transformation', :object => @transformation)
        page.visual_effect :highlight, 'transformation-list'
      end
    end
  end
  
  # Destroys a transformation
  def destroy
    @transformation = Transformation.find(params[:id])
    @transformation.remove_from_list
    @transformation.destroy
    render :update do |page|
      page.remove "transformation_#{params[:id]}"
      page.visual_effect :highlight, 'transformation-list'
    end
  end
  
  # Saves new order for transformation rules
  def reorder
    @vocabulary = Vocabulary.find(params[:id]) 
    @vocabulary.transformations.each do |t| 
      t.position = params['transformation-list'].index(t.id.to_s) + 1 
      t.save 
    end 
    render :nothing => true 
  end
  
  # Sets insertion point for conjugation pattern
  def update
    @transformation = Transformation.find(params[:id])
    @vocabulary = Vocabulary.find(params[:vocabulary_id])
    if @transformation
      param_name = @transformation.class.to_s.underscore.to_sym
      range = params[param_name].delete(:range).split(',').collect { |r| r.to_i }
      @transformation.set_range(range[0], range[1], params[param_name].delete(:start_in_back).to_i, params[param_name].delete(:use_open_range).to_i) unless range[0] == -1 && range[1] == -1
      @transformation.update_attributes(params[param_name])
      @transformation.save
    end
    render @transformation
  end
  
end
