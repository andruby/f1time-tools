require 'rubygems'
require 'sinatra'
  
root_dir = File.dirname(__FILE__)

Sinatra::Application.default_options.merge!(
  :views    => File.join(root_dir, 'views'),
  :app_file => File.join(root_dir, 'sinatra_app.rb'),
  :run => false,
  :env => :production
)

require 'sinatra_app.rb'
run Sinatra.application