###
# User 
###
set :user, "ulf"
 
### 
# Application name and location details 
### 
set :deploy_to, "/var/www/tuvocabulario.com/"
 
### 
# Rollout servers 
### 
role :app, "santa-cruz.ulfmoehring.net"
role :web, "santa-cruz.ulfmoehring.net"
role :db,  "santa-cruz.ulfmoehring.net", :primary => true
 
###
# Production Post-rollout task default overrides 
###

namespace :deploy do
  desc 'Start the application servers.'
  task :start, :roles => :app do
  end

  desc 'Stop the application servers.'
  task :stop, :roles => :app do
  end
end