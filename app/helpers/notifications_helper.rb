module NotificationsHelper

  #Options for a repeat period
  def repeat_periods
    ["Daily", "Weekly", "Monthly", "Yearly"]
  end 

  #Output a human-readable description of a repeat interval
  #repeat format : "D/W/M/Y"
  #Ex : "1/2/3/4" => "4 years,3 months,2 weeks,1 days"
  def print_repeat_interval(repeat)

    return "-" unless repeat.is_a?(String)
    
    #Grab each interval
    intervals = repeat.split '/' 
    if intervals.count != 4
      return "#Error.Wrong format"
    end
    
    #Count how many date intervals are set
    how_many = intervals.map { |p|  p != "0" ? 1 : 0 }.sum

    days    = {:name => "days",  :qt => intervals[0].to_i}
    weeks   = {:name => "weeks", :qt => intervals[1].to_i}
    months  = {:name => "months",:qt => intervals[2].to_i}
    years   = {:name => "years", :qt => intervals[3].to_i}
    periods = [years, months, weeks, days]

    to_display = ""

    for per in periods
      if per[:qt] > 0
        to_display << "#{per[:qt]} #{per[:name]}"    
        how_many -= 1
        to_display << "," unless how_many.zero? 
      end
    end
    
    to_display
  end
  
end
