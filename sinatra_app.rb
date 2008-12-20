require 'rubygems'
require 'sinatra'

get '/' do
  erb :index
end

post '/' do
  # <strong>GP of Magny Cours - France</strong>
  @gp_name = params[:data].scan(/<strong>GP of ([^<]+)<\/strong>/).flatten.first
  @lap_array = params[:data].scan(/javascript:showLapInfo\((\d+), (\d+), (\d+), '(\S+)', (\S+), (\d+), (\d+)\)/)
  @lap_array.collect! { |row| row.insert(4,parse_time(row[3])) }
  @lap_array.collect! { |row| row.collect! { |item| item.gsub('.',',') } } if params[:comma]
  erb :index
end

helpers do
  def parse_time(time_string)
    min,sec,usec = time_string.scan(/(\d+):(\d+).(\d+)/).first
    day_fraction = ( (min.to_f/(24*60)) + (sec.to_f/(24*60*60)) + (usec.to_f/(24*60*60*1000)) ).to_s
  end
end