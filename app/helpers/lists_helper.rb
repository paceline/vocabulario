module ListsHelper
  
  def lists_as_options(lists)
    options = []
    lists.each do |list|
      options << [list.name, list_path(list.permalink)]
    end
    return options
  end
  
end
