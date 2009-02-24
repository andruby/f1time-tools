require 'rubygems'
require 'sinatra'
require 'andand'

get '/' do
  erb :index
end

post '/' do
  # Look for the name of the GP (the andand keeps it working when nothing is found)
  @gp_name = params[:data].scan(/<strong>GP of ([^<]+)<\/strong>/).andand.flatten.andand.first
  
  # Extract laptimes into an array
  @lap_array = params[:data].scan(/javascript:showLapInfo\((\d+), (\d+), (\d+), '(\d+:\d+.\d+)', (\d+.\d+), (\d+), (\d+)\)/)
  
  if @gp_name && @lap_array
    # No errors
    # Rows -- 1: lap, 2: pos, 3: prev_pos, 4: time_string, 5: time dayfraction, 6: time sec, 7: gap, 8: fuel, 9: temp, 10: delta 
    # Parse the laptimes into dayfraction for easy excel integration
    @lap_array.collect! { |row| row.insert(4,parse_time(row[3])) }
    
    # Parse the laptimes into seconds for easy excel integration
    @lap_array.collect! { |row| row.insert(5,parse_time(row[3])*24*60*60) }
  
    # add delta median to every row
    @median_laptime = median(@lap_array.collect { |row| parse_time(row[3]) })
    @lap_array.collect! { |row| row << fraction_to_sec( parse_time(row[3]) - @median_laptime ) }
    
    # calculate csv string for the first chart
    @csv_for_chart_1 = @lap_array.collect { |row| [row[0],row[5],row[6]].join(';') }.join('\n')
    @csv_for_chart_2 = @lap_array.collect { |row| [row[0],row[7],row[8]].join(';') }.join('\n')
    
    # replace all periods by comma's if checkbox has been selected
    @lap_array.collect! { |row| row.collect! { |item| commatize(item) } } if params[:comma]
  else
    # gp_name is missing and/or no lapdata found
    @error = "Incorrect race report html"
  end
  
  erb :index
end

require 'helpers.rb'