###
# Load plugins
###
Dir['vendor/plugins/*/recipes/*.rb'].each { |plugin| load(plugin) }
 
### 
# Global Rollout options 
###
 
# Application and Repo
set :application, "vocabulario"
set :repository,  "git@github.com:paceline/vocabulario.git"
#set :branch, "1-0"
 
# Set upload folders as shared
set :symlinks, %w{config/database.yml config/initializers/site_keys.rb tmp vendor/plugins/acts_as_textiled vendor/plugins/gravatar } 
 
# Deployment options
set :deploy_via, :rsync_with_remote_cache
set :rsync_options, '-avzK --exclude=.git -e ssh' 
set :keep_releases, 3
set :use_sudo, false
 
# Software Configruation Management System
set :scm, :git
 
 
###
# Global Post-rollout task default overrides 
###
 
namespace :viget do 
  namespace :deploy do 
    
    desc '[internal] Creates Viget-specific config files and any symlinks specified in the configuration.'
    task :post_update_code do
      unless fetch(:symlinks,nil).nil?
        fetch(:symlinks).each do |link|
          run "rm -rf #{release_path}/#{link} && ln -nfs #{shared_path}/#{link} #{release_path}/#{link}"
        end
      end
    end
    
    desc '[internal] Announces deployments in one or more Campfire rooms.'
    task :campfire do
      # No campfire
    end
    
  end
end