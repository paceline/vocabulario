module ListsHelper
  
  def shorten_text(name)
    name.length > 30 ? "#{name[0..25]}..." : name
  end
  
end
