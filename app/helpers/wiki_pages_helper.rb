module WikiPagesHelper
  acts_as_wiki_pages_helper
  
  def wiki_user(user)
    user ? link_to(user.name, user.profile_url) : "&lt;Unknown&gt;"
  end
  
end