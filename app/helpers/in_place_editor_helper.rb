module InPlaceEditorHelper
  
  def in_place_input(db_model, db_attribute)
    editable = "<span id='in_place_#{db_model.class.to_s.downcase}-#{db_model.id}_#{db_attribute}' class='editable'>#{db_model.send(db_attribute)}</span>"
    form = form_for(db_model, :url => in_place_editor_path(:id => db_model.id), :remote => true, :html => { :style => 'display: none;' }) do |form|
      form.text_field db_attribute
    end
    raw(editable) + form
  end
  
  def in_place_select(db_model, db_attribute, choices = nil, label = 'name')
    rel = db_model.send(db_attribute)
    
    begin
      rel.class.descends_from_active_record? || rel.class.base_class().descends_from_active_record?
      attr_name = "#{db_attribute}_id".to_sym
      value = db_model.send(db_attribute).send(label)
      choices = Object.const_get(db_attribute.capitalize).find(:all).collect { |v| [v.send(label),v.id] }
      selected = db_model.send(db_attribute).id
    rescue
      attr_name = db_attribute
      value = db_model.send(db_attribute)
      selected = value
    end
    
    editable = "<span id='in_place_#{db_model.class.to_s.downcase}-#{db_model.id}_#{attr_name}' class='editable'>#{value}</span>"
    form = form_for(db_model, :url => in_place_editor_path(:id => db_model.id), :remote => true, :html => { :style => 'display: none;' }) do |form|
      form.select attr_name, choices, :selected => selected
    end
    raw(editable) + form
  end
  
end
