begin
  require 'rubygems'
  require 'uri'
  require 'tinder'

  after "deploy", "viget:deploy:campfire"
  after "deploy:migrations", "viget:deploy:campfire"
  after "deploy:rollback", "viget:deploy:campfire"

  namespace :viget do
    namespace :deploy do
      desc '[internal] Announces deployments in one or more Campfire rooms.'
      task :campfire do
        campfires = fetch(:campfires,nil)
        notify = fetch(:campfire_notify,nil)
        unless campfires.nil? || notify.nil?
          notify.each do |name|
            config = campfires[name]
            campfire = Tinder::Campfire.new(config[:domain], :ssl => config[:ssl])
            if campfire.login(config[:email], config[:password])
              if room = campfire.find_room_by_name(config[:room])
                logger.debug "sending message to #{config[:room]} on #{name.to_s} Campfire"
                message = "[CAP] %s just deployed revision %s from %s" % [
                  ENV['USER'],
                  current_revision,
                  URI.parse(fetch(:repository)).path
                ]
                if stage = fetch(:stage)
                  message << " to #{stage}"
                end
                room.speak "#{message}."
              else
                logger.debug "Campfire #{name.to_s} room #{config[:room]} not found"
              end
            else
              logger.debug "Campfire #{name.to_s} email and/or password incorrect"
            end
          end
        end
      end
    end
  end
rescue LoadError
  nil # skip campfire stuff if tinder can't be required
end