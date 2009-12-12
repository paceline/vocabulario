class Array
  
  # Fetches one or more objects from an array based on given attribute and value (e.g. :id, 1)
  def fetch_object(method, value)
    elements = []
    self.each do |element|
      elements << element if element.send(method) == value
    end
    case elements.size
      when 0 then nil
      when 1 then elements.first
      else elements
    end
  end
  
end