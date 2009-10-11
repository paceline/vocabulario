module ListsHelper
  
  def lists_as_options(lists)
    options = []
    lists.each do |list|
      name = list.name.length > 30 ? "#{list.name[0..30]}..." : list.name
      options << [name, list_path(list.permalink)]
    end
    return options
  end
  
end
