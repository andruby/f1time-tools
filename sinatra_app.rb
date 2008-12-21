require 'rubygems'
require 'sinatra'

get '/' do
  erb :index
end

post '/' do
  @gp_name = params[:data].scan(/<strong>GP of ([^<]+)<\/strong>/).flatten.first
  
  # Extract laptimes into an array
  @lap_array = params[:data].scan(/javascript:showLapInfo\((\d+), (\d+), (\d+), '(\S+)', (\S+), (\d+), (\d+)\)/)
  # Parse the laptimes into dayfraction for easy excel integration
  @lap_array.collect! { |row| row.insert(4,parse_time(row[3])) }
  
  # add delta median to every row
  @median_laptime = median(@lap_array.collect { |row| parse_time(row[3]) })
  @lap_array.collect! { |row| row << fraction_to_sec( parse_time(row[3]) - @median_laptime ) }
  
  # replace all periods by comma's if checkbox has been selected
  @lap_array.collect! { |row| row.collect! { |item| commatize(item) } } if params[:comma]
  
  # Launch the template with index
  erb :index
end

require 'helpers.rb'