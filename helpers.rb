helpers do
  def parse_time(time_string)
    min,sec,usec = time_string.scan(/(\d+):(\d+).(\d+)/).first
    day_fraction = (min.to_f/(24*60)) + (sec.to_f/(24*60*60)) + (usec.to_f/(24*60*60*1000))
  end
  
  def commatize(value,if_condition=true)
    if_condition ? value.to_s.gsub('.',',') : value
  end
  
  def fraction_to_sec(fraction)
    fraction*24*60*60
  end
  
  def median(numbers)
    ordered = numbers.sort
    n = (ordered.size - 1) / 2 # Middle of the array
    n2 = (ordered.size) / 2 # Other middle of the array.
    median = (ordered[n] + ordered[n2]) / 2.0
  end
  
  def html_escape(s)
    s.to_s.gsub(/[&"><]/,'')
  end
  
  def xml_child_int(xml,child_name)
    xml.at(child_name).inner_text.to_i
  end
  
  alias :h :html_escape
end