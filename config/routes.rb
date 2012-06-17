Vocabulario::Application.routes.draw do
  # Named routes
  # ============
  
  # User and login stuff
  devise_for :users
  match '/lists/:list_id/test' => 'scores#new', :as => :test_from_list
  match '/wiki/:path/test' => 'scores#new', :as => :test_from_page
  match '/test' => 'scores#new', :as => :test
  
  # Vocabularies
  match '/vocabularies/:id/unlink/:link' => 'vocabularies#unlink', :as => :vocabularies_unlink
  match '/vocabularies/page/:page' => 'vocabularies#index', :as => :vocabularies_with_page
  match '/vocabularies/by_type/:id' => 'vocabularies#by_type', :as => :vocabularies_by_type
  match '/vocabularies/by_tag/:id' => 'vocabularies#by_tag', :as => :vocabularies_by_tag
  match '/vocabularies/by_language/:id' => 'vocabularies#by_language', :as => :vocabularies_by_language
  match '/vocabularies/by_user/:id' => 'vocabularies#by_user', :as => :vocabularies_by_user
  
  # List aliases
  match '/lists/:id/feed/:tense_id' => 'lists#show', :as => :feed_list_with_tense
  
  # Oauth stuff
  resources :oauth_clients
  match '/oauth/test_request',  :to => 'oauth#test_request',  :as => :test_request
  match '/oauth/token',         :to => 'oauth#token',         :as => :token
  match '/oauth/access_token',  :to => 'oauth#access_token',  :as => :access_token
  match '/oauth/request_token', :to => 'oauth#request_token', :as => :request_token
  match '/oauth/authorize',     :to => 'oauth#authorize',     :as => :authorize
  match '/oauth/revoke',        :to => 'oauth#revoke',        :as => :revoke
  match '/oauth',               :to => 'oauth#index',         :as => :oauth
  
  # Wiki
  match '/wiki/by_tag/:id' => 'wiki_pages#by_tag', :as => :wiki_by_tag
  match '/wiki/prefix' => 'wiki_pages#prefix'
  wiki_root '/wiki'
  
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
      post 'reorder'
      post 'tense'
      delete 'unlink'
    end
    resources :scores
  end
  
  resources :scores do
    collection do
      get 'change_test_type'
      post 'update_languages'
      post 'update_tags'
      post 'options_for_list'
    end
  end
  
  resources :statistics
    
  resources :users do
    collection do
      get 'current'
    end
    member do
      put 'admin'
      post 'defaults'
    end
    resources :scores, :lists, :status
  end
    
  resources :vocabularies do
    collection do
      get 'import'
      post 'import'
      post 'live'
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
      get 'set_language'
    end
  end
    
  resources :tags

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => "vocabularies#index"
end
