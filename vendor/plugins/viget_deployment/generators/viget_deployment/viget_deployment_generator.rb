class VigetDeploymentGenerator < Rails::Generator::Base
  attr_accessor :application

  def initialize(*runtime_args)
    super(*runtime_args)
    @application = args[0]
    @application ||= File.basename(RAILS_ROOT)
  end
  
  def manifest
    record do |m|
      m.template 'database.rb', File.join('config','database.yml-sample')
      m.file 'Capfile', 'Capfile'
      m.template 'deploy.rb', File.join('config','deploy.rb')
      m.directory File.join('config','deploy')
      m.file 'production.rb', File.join('config','deploy','production.rb')
      m.file 'staging.rb', File.join('config','deploy','staging.rb')
      m.file File.join('..', '..', '..', '..', '..', '..', 'config','environments','production.rb'),
             File.join('config','environments','staging.rb')
    end
  end
end
