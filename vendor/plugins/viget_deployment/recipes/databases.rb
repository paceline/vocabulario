require 'yaml'

namespace :viget do
  namespace :db do
    
    desc 'Query the latest version of the database'
    task :version, :roles => :db, :only => { :primary => true } do
      rake = fetch(:rake, "rake")
      run "cd #{current_release}; #{rake} RAILS_ENV=#{rails_env} db:version"
    end
    
    desc 'Dump the database for the given stage.'
    task :dump, :roles => :db do
      begin
        dbc=YAML.load(File.open('config/database.yml'))[stage.to_s]
        logger.debug "dumping #{stage} database"
        run "mysqldump -h#{dbc['host']} -u#{dbc['username']} -p#{dbc['password']} #{dbc['database']} >#{deploy_to}/dump.sql"
      rescue NoMethodError
        raise RuntimeError,"No such stage: #{stage}"
      end
    end

    desc 'Restore the database for the given stage.'
    task :restore, :roles => :db do
      begin
        dbc=YAML.load(File.open('config/database.yml'))[stage]
        logger.debug "restoring #{stage} database from dump"
        run("mysql -h#{dbc['host']} -u#{dbc['username']} -p#{dbc['password']} #{dbc['database']} <#{deploy_to}/dump.sql") do |channel,stream,data|
          unless data.empty?
            raise RuntimeError,"Couldn't restore #{stage} database from dump"
          end
        end
      rescue NoMethodError
        raise RuntimeError,"No such stage: #{stage}"
      end
    end
  end
end
