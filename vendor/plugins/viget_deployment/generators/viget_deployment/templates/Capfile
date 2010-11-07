load 'deploy' if respond_to?(:namespace) # cap2 differentiator
set :stages, %w(staging production)
Dir['vendor/plugins/*/recipes/*.rb'].each { |plugin| load(plugin) }
load 'config/deploy'
