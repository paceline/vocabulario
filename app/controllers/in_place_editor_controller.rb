class InPlaceEditorController < ApplicationController
  
  # Layout
  layout nil
  
  # Filters
  before_filter :login_required
  
  # Globally Handle in_place_edit update requests
  def update
    @type = Object.const_get(find_type_in_params(params))
    @entity = @type.descends_from_active_record? ? @type.find(params[:id]) : @type.base_class.find(params[:id])
    @attribute = params[@type.to_s.downcase.to_sym].keys.first
    @entity.update_attributes(params[@type.to_s.downcase.to_sym])
  end
  
  private
  
    def find_type_in_params(params)
      params.each_pair do |key, value|
        return key.capitalize if value.class == ActiveSupport::HashWithIndifferentAccess
      end
    end
  
end
