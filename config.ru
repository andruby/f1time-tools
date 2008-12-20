require 'rubygems'
require 'sinatra'
  
Sinatra::Application.default_options.merge!(
  :run => false,
  :env => :production
)
  
require 'sinatra_app.rb'
run Sinatra.application