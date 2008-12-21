require 'rubygems'
require 'sinatra'
require 'andand'

get '/' do
  erb :index
end

post '/' do
  # Look for the name of the GP (the andand keeps it working when nothing is found)
  @gp_name = params[:data].scan(/<strong>GP of ([^<]+)<\/strong>/).andand.flatten.andand.first
  
  if @gp_name
    # Extract laptimes into an array
    @lap_array = params[:data].scan(/javascript:showLapInfo\((\d+), (\d+), (\d+), '(\d+:\d+.\d+)', (\d+.\d+), (\d+), (\d+)\)/)
    # Parse the laptimes into dayfraction for easy excel integration
    @lap_array.collect! { |row| row.insert(4,parse_time(row[3])) }
  
    # add delta median to every row
    @median_laptime = median(@lap_array.collect { |row| parse_time(row[3]) })
    @lap_array.collect! { |row| row << fraction_to_sec( parse_time(row[3]) - @median_laptime ) }
  
    # replace all periods by comma's if checkbox has been selected
    @lap_array.collect! { |row| row.collect! { |item| commatize(item) } } if params[:comma]
  
    # Launch the template with index
    erb :index
  else
    # There has been an error
    @error = "Incorrect race report html"
    erb :index
  end
end

require 'helpers.rb'