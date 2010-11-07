require 'rubygems'
require 'capistrano/ext/multistage'

after "multistage:ensure", "viget:config:defaults"
after "deploy:update_code", "viget:deploy:post_update_code"

namespace :deploy do
  desc 'Signal Passenger to restart the application.'
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end
end

namespace :viget do
  namespace :deploy do
    desc '[internal] Creates Viget-specific config files and any symlinks specified in the configuration.'
    task :post_update_code do
      run "cp #{release_path}/config/database.yml-sample #{release_path}/config/database.yml"
      unless fetch(:symlinks,nil).nil?
        fetch(:symlinks).each do |link|
          run "rm -rf #{release_path}/#{link} && ln -nfs #{shared_path}/#{link} #{release_path}/#{link}"
        end
      end
      # FIXME: this may no longer be necessary; Passenger might be able to do the right thing
      # by now
      run "sed -i '1iENV[\"RAILS_ENV\"] = \"#{stage}\"' #{release_path}/config/environment.rb"
    end
  end

  namespace :config do
    desc '[internal] Sets default values for some variables.'
    task :defaults do
      set :rails_env, fetch(:stage).to_s
    end
  end
end
