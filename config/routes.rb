Vocabulario::Application.routes.draw do
  # The priority is based upon order of creation:
  # first created -> highest priority.
  
  # Named routes
  # ============
  
  # User and login stuff
  match '/logout' => 'clearance/sessions#destroy', :as => :signout
  match '/login' => 'clearance/sessions#new', :as => :sign_in
  match '/signup' => 'users#new', :as => :sign_up
  match '/community' => 'users#index', :as => :community
  match '/lists/:list_id/test' => 'scores#new', :as => :test_from_list
  match '/test' => 'scores#new', :as => :test
  
  # Vocabularies
  match '/vocabularies/:id/unlink/:link' => 'vocabularies#unlink', :as => :vocabularies_unlink
  match '/vocabularies/page/:page' => 'vocabularies#index', :as => :vocabularies_with_page
  match '/vocabularies/by_type/:id' => 'vocabularies#by_type', :as => :vocabularies_by_type
  match '/vocabularies/by_tag/:id' => 'vocabularies#by_tag', :as => :vocabularies_by_tag
  match '/vocabularies/by_language/:id' => 'vocabularies#by_language', :as => :vocabularies_by_language
  match '/vocabularies/by_user/:id' => 'vocabularies#by_user', :as => :vocabularies_by_user
 
  # Oauth
  match '/oauth/test_request' => 'oauth#test_request', :as => :test_request
  match '/oauth/access_token' => 'oauth#access_token', :as => :access_token
  match '/oauth/request_token' => 'oauth#request_token', :as => :request_token
  match '/oauth/authorize' => 'oauth#authorize', :as => :authorize
  match '/oauth' => 'oauth#index', :as => :oauth
  
  # List aliases
  match '/lists/:id/print/:tense_id' => 'lists#print', :as => :print_list_with_tense
  match '/lists/:id/feed/:tense_id' => 'lists#show', :as => :feed_list_with_tense
  
  # Timeline aliases
  match '/timeline' => 'status#index', :as => :timeline
  match '/users/:user_id/timeline' => 'status#index', :as => :user_timeline
  
  
  # Resources
  # =========
  
  resource :in_place_editor, :controller => 'in_place_editor'
  
  resources :comments
  
  resources :patterns do
      member do
        post 'reorder'
        post 'add_verb'
        delete 'remove_verb'
      end
      resources :rules
  end
  
  resources :rules do
    collection do
      post 'autocomplete'
      post 'test'
    end
  end
  
  resources :tenses, :controller => 'conjugation_times', :as => 'tenses' do
    collection do
      get 'tab'
      get 'tabs'
    end
    member do
      post 'live'
    end
    resources :patterns, :vocabularies
  end
  
  resources :languages, :controller => :vocabularies
  
  resources :lists do
    collection do
      post 'switch'
    end
    member do
      post 'newitem'
      post 'copy_move'
      put 'copy_move'
      post 'live'
      get 'show_options_menu'
      get 'sort'
      get 'print'
      post 'reorder'
      post 'tense'
      delete 'unlink'
    end
    resources :scores
  end
  
  resources :oauth_clients
  
  resources :pronouns, :controller => 'people', :as => 'pronouns'
  
  resources :scores do
    collection do
      get 'change_test_type'
      post 'update_languages'
      post 'update_tags'
      post 'options_for_list'
    end
  end
  
  resources :statistics
  
  resources :status do 
    collection do
      get 'user_timeline'
    end
  end
  
  resource :password, :controller => 'clearance/passwords'
  
  resource :session, :controller => 'clearance/sessions'
  
  resources :users do
    collection do
      get 'current'
    end
    member do
      put 'admin'
      put 'password'
      get 'statistics'
      post 'statistics'
      post 'defaults'
    end
    resources :scores, :lists, :status
  end
    
  resources :vocabularies do
    collection do
      get 'import'
      post 'import'
      post 'live'
      post 'refresh_language'
      post 'preview'
      get 'redirect'
    end
    member do
      put 'apply_conjugation'
      post 'apply_tags'
      post 'apply_type'
      get 'conjugate'
      delete 'unlink'
      get 'translate'
    end
  end
    
  resources :tags

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => "status#index"
end