module InPlaceMacrosHelper
  # Makes an HTML element specified by the DOM ID +field_id+ become an in-place
  # editor of a property.
  #
  # A form is automatically created and displayed when the user clicks the element,
  # something like this:
  #   <form id="myElement-in-place-edit-form" target="specified url">
  #     <input name="value" text="The content of myElement"/>
  #     <input type="submit" value="ok"/>
  #     <a onclick="javascript to cancel the editing">cancel</a>
  #   </form>
  # 
  # The form is serialized and sent to the server using an AJAX call, the action on
  # the server should process the value and return the updated value in the body of
  # the reponse. The element will automatically be updated with the changed value
  # (as returned from the server).
  # 
  # Required +options+ are:
  # <tt>:url</tt>::       Specifies the url where the updated value should
  #                       be sent after the user presses "ok".
  # 
  # Addtional +options+ are:
  # <tt>:rows</tt>::              Number of rows (more than 1 will use a TEXTAREA)
  # <tt>:cols</tt>::              Number of characters the text input should span (works for both INPUT and TEXTAREA)
  # <tt>:size</tt>::              Synonym for :cols when using a single line text input.
  # <tt>:cancel_text</tt>::       The text on the cancel link. (default: "cancel")
  # <tt>:save_text</tt>::         The text on the save link. (default: "ok")
  # <tt>:loading_text</tt>::      The text to display while the data is being loaded from the server (default: "Loading...")
  # <tt>:saving_text</tt>::       The text to display when submitting to the server (default: "Saving...")
  # <tt>:external_control</tt>::  The id of an external control used to enter edit mode.
  # <tt>:load_text_url</tt>::     URL where initial value of editor (content) is retrieved.
  # <tt>:options</tt>::           Pass through options to the AJAX call (see prototype's Ajax.Updater)
  # <tt>:with</tt>::              JavaScript snippet that should return what is to be sent
  #                               in the AJAX call, +form+ is an implicit parameter
  # <tt>:script</tt>::            Instructs the in-place editor to evaluate the remote JavaScript response (default: false)
  # <tt>:click_to_edit_text</tt>::The text shown during mouseover the editable text (default: "Click to edit")
  def in_place_editor(field_id, options = {})
    function =  "new Ajax.InPlaceEditor("
    function << "'#{field_id}', "
    function << "'#{url_for(options[:url])}'"

    js_options = {}

    if protect_against_forgery?
      options[:with] ||= "Form.serialize(form)"
      options[:with] += " + '&authenticity_token=' + encodeURIComponent('#{form_authenticity_token}')"
    end

    js_options['cancelText'] = %('#{options[:cancel_text]}') if options[:cancel_text]
    js_options['okText'] = %('#{options[:save_text]}') if options[:save_text]
    js_options['loadingText'] = %('#{options[:loading_text]}') if options[:loading_text]
    js_options['savingText'] = %('#{options[:saving_text]}') if options[:saving_text]
    js_options['rows'] = options[:rows] if options[:rows]
    js_options['cols'] = options[:cols] if options[:cols]
    js_options['size'] = options[:size] if options[:size]
    js_options['externalControl'] = "'#{options[:external_control]}'" if options[:external_control]
    js_options['loadTextURL'] = "'#{url_for(options[:load_text_url])}'" if options[:load_text_url]        
    js_options['ajaxOptions'] = options[:options] if options[:options]
    js_options['htmlResponse'] = !options[:script] if options[:script]
    js_options['callback']   = "function(form) { return #{options[:with]} }" if options[:with]
    js_options['clickToEditText'] = %('#{options[:click_to_edit_text]}') if options[:click_to_edit_text]
    js_options['textBetweenControls'] = %('#{options[:text_between_controls]}') if options[:text_between_controls]
    function << (', ' + options_for_javascript(js_options)) unless js_options.empty?
    
    function << ')'

    javascript_tag(function)
  end
  
  # Renders the value of the specified object and method with in-place editing capabilities.
  def in_place_editor_field(object, method, tag_options = {}, in_place_editor_options = {})
    instance_tag = ::ActionView::Helpers::InstanceTag.new(object, method, self)
    tag_options = {:tag => "span",
                   :id => "#{object}_#{method}_#{instance_tag.object.id}_in_place_editor",
                   :class => "in_place_editor_field"}.merge!(tag_options)
    in_place_editor_options[:url] = in_place_editor_options[:url] || url_for({ :action => "set_#{object}_#{method}", :id => instance_tag.object.id })
    tag = content_tag(tag_options.delete(:tag), h(instance_tag.value(instance_tag.object)),tag_options)
    return tag + in_place_editor(tag_options[:id], in_place_editor_options)
  end
  
  ##
  # Renders an in-place select similar to in_place_editor.  Options are the same as those supported by
  # InPlaceMacrosHelper.in_place_editor(), plus some extra ones to deal with the list:
  #
  # <tt>:collection</tt>::              The collection that will be used to build the list options
  # <tt>:load_collection_url</tt>::     A URL that will return the collection in JSON format
  # <tt>:loading_collection_text</tt>:: Text to display while the collection is loading
  # <tt>:loading_class_name</tt>::      Class applied to form while the collection is loading
  ##
  def in_place_select(field_id, options = {})
    function =  "new Ajax.InPlaceCollectionEditor("
    function << "'#{field_id}', "
    function << "'#{url_for(options[:url])}'"

    js_options = {}
    
    if protect_against_forgery?
      options[:with] ||= "Form.serialize(form)"
      options[:with] += " + '&authenticity_token=' + encodeURIComponent('#{form_authenticity_token}')"
    end
    
    js_options['cancelText'] = %('#{options[:cancel_text]}') if options[:cancel_text]
    js_options['okText'] = %('#{options[:save_text]}') if options[:save_text]
    js_options['loadingText'] = %('#{options[:loading_text]}') if options[:loading_text]
    js_options['savingText'] = %('#{options[:saving_text]}') if options[:saving_text]
    js_options['rows'] = options[:rows] if options[:rows]
    js_options['cols'] = options[:cols] if options[:cols]
    js_options['size'] = options[:size] if options[:size]
    js_options['externalControl'] = "'#{options[:external_control]}'" if options[:external_control]
    js_options['loadTextURL'] = "'#{url_for(options[:load_text_url])}'" if options[:load_text_url]
    js_options['ajaxOptions'] = options[:options] if options[:options]
    js_options['evalScripts'] = options[:script] if options[:script]
    js_options['onComplete'] = options[:on_complete] if options[:on_complete]
    js_options['callback']   = "function(form) { return #{options[:with]} }" if options[:with]
    js_options['clickToEditText'] = %('#{options[:click_to_edit_text]}') if options[:click_to_edit_text]

    js_options['collection'] = %(#{js_collection_for(options[:collection])}) if options[:collection]
    js_options['loadCollectionURL'] = %('#{url_for(options[:load_collection_url])}') if options[:load_collection_url]
    js_options['loadingCollectionText'] = %('#{options[:loading_collection_text]}') if options[:loading_collection_text]
    js_options['loadingClassName'] = %('#{options[:loading_class_name]}') if options[:loading_class_name]

    function << (', ' + options_for_javascript(js_options)) unless js_options.empty?
    function << ')'
    javascript_tag(function)
  end
  
  # Renders the value of the specified object and method with in-place editing capabilities.
  def in_place_select_field(object, method, tag_options = {}, in_place_editor_options = {})
    instance_tag = ::ActionView::Helpers::InstanceTag.new(object, method, self)
    label = tag_options.key?(:label) ? tag_options.delete(:label) : instance_tag.value(instance_tag.object)
    tag_options = {:tag => "span",
                   :id => "#{object}_#{method}_#{instance_tag.object.id}_in_place_editor",
                   :class => "in_place_editor_field"}.merge!(tag_options)
    in_place_editor_options[:url] = in_place_editor_options[:url] || url_for({ :action => "set_#{object}_#{method}", :id => instance_tag.object.id })
    tag = content_tag(tag_options.delete(:tag), h(label),tag_options)
    return tag + in_place_select(tag_options[:id], in_place_editor_options)
  end

  private

    ##
    # Converts the given collection to a javascript string suitable for rendering options in a select list.
    # The collection key becomes the option value, while the collection value becomes the body of the <option> tags.
    ##
    def js_collection_for(collection)
      js = '['
      collection.each { |key, value| js << "[#{to_javascript(value)},#{to_javascript(key)}]," }
      js = js.chop
      js << ']'
    end

    ##
    # Surrounds the given value with single quotes if it's not a number so JavaScript will render/process the select
    # option values correctly.
    ##
    def to_javascript(value)
      return value if value.is_a?(Numeric)
      "'#{value}'"
    end

end
