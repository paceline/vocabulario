module InPlaceEditing
  def self.included(base)
    base.extend(ClassMethods)
  end

  # Example:
  #
  #   # Controller
  #   class BlogController < ApplicationController
  #     in_place_edit_for :post, :title
  #   end
  #
  #   # View
  #   <%= in_place_editor_field :post, 'title' %>
  #
  module ClassMethods
    def in_place_edit_for(object, attribute, options = {})
      define_method("set_#{object}_#{attribute}") do
        unless [:post, :put].include?(request.method) then
          return render(:text => 'Method not allowed', :status => 405)
        end
        @item = object.to_s.camelize.constantize.find(params[:id])
        oldvalue = @item.send(attribute)
        @item.send("#{attribute}=",params[:value])
        if @item.valid?
          @item.save 
          html = options.key?(:method) ? @item.send(attribute.to_s.split('_').first).send(options[:method]) : @item.send(attribute)
        else
          html = oldvalue
        end
        render :text => CGI::escapeHTML(html.to_s)
      end
    end
  end
end
