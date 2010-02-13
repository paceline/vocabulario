ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.
  
  # Named routes
  # ============
  
  # User and login stuff
  map.logout '/logout', :controller => 'clearance/sessions', :action => 'destroy'
  map.login '/login', :controller => 'clearance/sessions', :action => 'new'
  map.signup '/signup', :controller => 'users', :action => 'new'
  map.community '/community', :controller => 'users', :action => 'index'
  map.test_from_list '/lists/:list_id/test.:format', :controller => 'scores', :action => 'new'
  map.test '/test', :controller => 'scores', :action => 'new'
  
  # Vocabularies
  map.vocabularies_unlink '/vocabularies/:id/unlink/:link', :controller => 'vocabularies', :action => 'unlink'
  map.vocabularies_with_page '/vocabularies/page/:page', :controller => 'vocabularies', :action => 'index'
  map.vocabularies_by_type '/vocabularies/by_type/:id.:format', :controller => 'search', :action => 'by_type'
  map.vocabularies_by_tag '/vocabularies/by_tag/:id.:format', :controller => 'search', :action => 'by_tag'
  map.vocabularies_by_language '/vocabularies/by_language/:id.:format', :controller => 'search', :action => 'by_language'
  map.vocabularies_by_user '/vocabularies/by_user/:id.:format', :controller => 'search', :action => 'by_user'
  
  # Oauth
  map.test_request '/oauth/test_request', :controller => 'oauth', :action => 'test_request'
  map.access_token '/oauth/access_token', :controller => 'oauth', :action => 'access_token'
  map.request_token '/oauth/request_token', :controller => 'oauth', :action => 'request_token'
  map.authorize '/oauth/authorize', :controller => 'oauth', :action => 'authorize'
  map.oauth '/oauth', :controller => 'oauth', :action => 'index'
  
  # List aliases
  map.print_list_with_tense '/lists/:id/print/:tense_id.:format', :controller => 'lists', :action => 'print'
  map.feed_list_with_tense '/lists/:id/feed/:tense_id.:format', :controller => 'lists', :action => 'show'
  
  # Timeline aliases
  map.timeline '/timeline.:format', :controller => 'status', :action => 'index'
  map.user_timeline '/users/:user_id/timeline.:format', :controller => 'status', :action => 'index'
  
  
  # Resources
  # =========
  
  map.resources :conjugations
  map.resources :conjugation_times, :as => 'tenses', :has_many => :conjugations
  map.resources :languages, :controller => :vocabularies
  map.resources :lists,
    :collection => { :switch => :get, :live => :get },
    :member => { :newitem => :post, :copy_move => [:put, :post], :show_options_menu => :post, :sort => :post, :print => :get, :reorder => :post, :unlink => :delete },
    :has_many => :scores
    
  map.resources :oauth_clients
  map.resources :people, :as => 'pronouns'
  map.resource :search, :controller => :search, :member => { :live => :get }
  map.resources :scores, :collection => { :change_test_type => :get, :update_languages => :get, :update_tags => :get, :options_for_list => :get }
  map.resources :statistics
  map.resources :status, :collection => { :user_timeline => :get }
  map.resources :transformations, :member => { :reorder => :post }
  map.resources :users,
    :collection => { :current => :get },
    :member => { :admin => :put, :password => :put, :statistics => [:get, :post] },
    :has_many => [:scores, :lists, :status]
  
  map.resources :vocabularies,
    :member => { :apply_conjugation => :put, :unapply_conjugation => :delete, :apply_tags => :post, :apply_type => :post, :tag => :post, :unlink => :delete },
    :collection => { :import => [:get, :post], :refresh_language => :get, :review => :get, :redirect => :get },
    :has_many => [:conjugations, :transformations]
    
  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.root :controller => 'status'

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
