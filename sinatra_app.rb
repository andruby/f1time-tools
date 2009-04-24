require 'rubygems'
require 'sinatra'
require 'andand'
require 'hpricot'
require 'lib/math_statistics'
require 'activesupport'

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

get '/practice_xml' do
  erb :practice_xml
end

post '/practice_xml' do
  data = Hpricot::XML(params[:data])
  # Look for the name of the GP (the andand keeps it working when nothing is found)
  @track_title = (data/:track_name).inner_text + ' ( ' + (data/:track_country_name).inner_text + ' )' 
  
  @sections = {}
  1.upto(3) { |x| @sections[x] = (data/:"time_#{x}").collect {|t| t.inner_text.to_f } }
  total = @sections.collect { |s| s.last.median }.sum
  @section_weight = @sections.collect { |s| s.last.median / total.to_f }
  
  # setup data init
  @setup_data = {}
  PARTS = [['front_wing','steer'],['rear_wing','grip'],['suspension'],['gears']]
  
  # put drp stuff in an easy array
  # drp_data[lap_nr][skill_id]
  # skills are:
  SKILLS = %w{feedback_dqp acceleration braking top_speed kerb_use racing_line}
  @drp_data = []
  
  # get the data from each lap
  (data/:laps/:data).each do |lap| 
    lap_nr = xml_child_int(lap,'lapnr')
    @drp_data[lap_nr-1] ||= []
    1.upto(3) do |section|
      PARTS.each do |part|
        # initialize arrays
        @setup_data[part.first] ||= {}
        @setup_data[part.first][section] ||= {}
        @setup_data[part.first][section]['min'] ||= [0]
        @setup_data[part.first][section]['max'] ||= [100]
        # fill the arrays with minima and maxima
        @setup_data[part.first][section]['min'] << xml_child_int(lap,part.first) if xml_child_int(lap,"feedback_#{part.last}_#{section}") == 1
        @setup_data[part.first][section]['max'] << xml_child_int(lap,part.first) if xml_child_int(lap,"feedback_#{part.last}_#{section}") == -1
      
      end # part
    end # section
    SKILLS.each_index do |skill_id|
      @drp_data[lap_nr-1][skill_id] = xml_child_int(lap,SKILLS[skill_id])
    end
  end # laps

  # get the minima and maxima
  PARTS.each do |part|
    avgs = {}
    1.upto(3) do |section|
      # fill the arrays with minima and maxima
      @setup_data[part.first][section]['min'] = @setup_data[part.first][section]['min'].max
      @setup_data[part.first][section]['max'] = @setup_data[part.first][section]['max'].min
      @setup_data[part.first][section]['avg'] = (@setup_data[part.first][section]['min'] + @setup_data[part.first][section]['max'])/2.to_f
      avgs[section] = @setup_data[part.first][section]['avg']
    end
    @setup_data[part.first]['weighted_avg'] = avgs.collect { |section,avg| avg*@section_weight[section-1] }.sum
  end 
  

  erb :practice_xml
end

require 'helpers.rb'