set :repository, "svn://svn.lab.viget.com/#{application}/trunk"
set :deploy_to, "/var/www/#{application}/staging"

role :web, "web.#{application}.com"
role :app, "app.#{application}.com"
role :db, "db.#{application}.com", :primary => true

# Uncomment one of these lines:
# set :user, "apache"   # for RHEL hosts
# set :user, "www-data" # for Ubuntu hosts

set :deploy_via, :rsync_with_remote_cache
set :local_cache, ".rsync_cache/staging"
