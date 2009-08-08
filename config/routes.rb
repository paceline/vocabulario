ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.
  
  # Named routes
  # ============
  
  # User and login stuff
  map.activate '/activate/:activation_code', :controller => 'users', :action => 'activate', :activation_code => nil
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.login '/login', :controller => 'sessions', :action => 'new'
  map.register '/register', :controller => 'users', :action => 'create'
  map.signup '/signup', :controller => 'users', :action => 'new'
  
  # Vocabularies
  map.vocabularies_unlink '/vocabularies/:id/unlink/:link', :controller => 'vocabularies', :action => 'unlink'
  map.vocabularies_with_page '/vocabularies/page/:page', :controller => 'vocabularies', :action => 'index'
  map.vocabularies_by_type '/vocabularies/by_type/:id', :controller => 'search', :action => 'by_type'
  map.vocabularies_by_tag '/vocabularies/by_tag/:id', :controller => 'search', :action => 'by_tag'
  map.vocabularies_by_language '/vocabularies/by_language/:id', :controller => 'search', :action => 'by_language'
  
  # Resources
  # =========
  
  map.resources :conjugations
  map.resources :conjugation_times, :as => 'tenses'
  map.resources :languages, :controller => :vocabularies
  map.resource :search, :controller => :search, :member => { :live => :get }
  map.resource :session
  map.resources :scores, :collection => { :change_test_type => :get }
  
  map.resources :users,
    :collection => { :forgot_password => [:get, :post] },
    :member => { :suspend => :put, :unsuspend => :put, :purge => :delete, :admin => :put }
  
  map.resources :transformations, :member => { :reorder => :post }
  
  map.resources :vocabularies,
    :member => { :apply_conjugation => :put, :unapply_conjugation => :delete, :apply_tags => :post, :apply_type => :post, :tag => :post, :unlink => :delete },
    :collection => { :import => [:get, :post], :refresh_language => :get, :select => :get, :tags_for_language => :get },
    :has_many => [:conjugations, :transformations]

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.root :controller => 'scores', :action => 'new'

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
