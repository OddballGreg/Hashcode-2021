require 'pry'
start_time = Time.now

###### Comments

#Flights


###### Methods



###### Basic IO Checks

if ARGV.size.zero?
  puts "Please provide a input filename as the first arguement!"
  exit
end

FILENAME = ARGV.first

unless File.exists?(FILENAME)
  puts "Please provide an existing filename as first arguement!"
  exit
end

######## Data Structure

simulation_length = 0 #number of sections the simulation will run for
intersection_count = 0
street_count = 0
car_count = 0
points_per_car_success = 0

intersections = {}
streets = {} #name => list of characteristics
cars = {}



######## File Read and Parse

File.readlines(FILENAME).each.with_index do |line, index|
  line_parts = line.split(' ')

  if index == 0
    simulation_length = line_parts[0].to_i
    intersection_count = line_parts[1].to_i
    street_count = line_parts[2].to_i
    car_count = line_parts[3].to_i
    points_per_car_success = line_parts[4].to_i
  elsif index <= (street_count)
    street_details = line_parts
    street = {
      name: street_details[2].freeze, #what does freeze mean?
      si: street_details[0].to_i, # start of street
      ei: street_details[1].to_i, # end of street
      seconds: street_details[3].to_i, # seconds taken 
      weight: 0
    }

    intersections[street[:ei]] ||= {
      streets: [],
      cars: []
    }
    intersections[street[:ei]][:streets] << street[:name]
    
    streets[street_details[2]] = street
  else  # After initial line and all roads, read cars
    next if line.size.zero? #no blank lines in file
    car = {
      number_of_streets: line_parts[0],
      path: line_parts[1..-1],
      path_length: line_parts[2..-1].sum{|street_name| streets[street_name][:seconds]}
    }
    car_id = index - street_count - 1
    cars[car_id] = car
    intersections[streets[line_parts[1]][:ei]][:cars] << car_id
    car[:path].each{|street_name| 
      streets[street_name][:weight] += 1 
      streets[street_name][:weight] += 1 if car[:path][1] == street_name
    }
  end
end


######## Algorithm
average_street_length = streets.sum{|name, street| street[:seconds]} / street_count
average_incoming_streets = intersections.sum{|id, int| int[:streets].size} / intersection_count
average_street_weight = streets.sum{|name, street| street[:weight]} / street_count
max_street_weight = streets.map{|name, street| street[:weight]}.max

current_cars = cars.reject{|id, car| car[:path_length] > simulation_length} #todo, make fasta

output = []

traveled_roads = current_cars.map{|id, car| car[:path]}.flatten.uniq
important_intersections = traveled_roads.map do |road|
  inter_id = streets[road][:ei]
  { inter_id => intersections[inter_id] }
end.reduce(&:merge)

highest_timing = 0

output << important_intersections.size.to_s
important_intersections.each do |k,v|
  output << k
  output << v[:streets].size
  if v[:streets].length > 1
    v[:streets] = v[:streets].sort do |street_name_a, street_name_b|
      street_a = streets[street_name_a]
      street_b = streets[street_name_b]
      intersection_a = intersections[street_a[:ei]]
      intersection_b = intersections[street_b[:ei]]
      intersection_a[:cars].length <=> intersection_b[:cars].length
    end 
  end

  v[:streets].each do |street_name|
    street = streets[street_name]
    
    weight = (street[:weight] / street[:seconds]).floor
    intersection = intersections[street[:ei]]
    intersection_streets = intersection[:streets].map{|street_name| streets[street_name] }
    intersection_average_weight = intersection_streets.sum{_1[:weight]}.to_f / intersection_streets.size
    intersection_average_seconds = intersection_streets.sum{_1[:seconds]}.to_f / intersection_streets.size
    if street[:weight] > intersection_average_weight
      weight -= 1
    end

    if street[:seconds] > intersection_average_seconds
      weight -= 1
    end

    # weight = [1, [((street[:weight] / street[:seconds])).ceil, simulation_length - 1].min].max.to_i

    bounded_timing = if FILENAME == 'inputs/d.txt'
      [1, [weight, simulation_length - 1].min].max.to_i
    else
      [1, [weight, 25].min].max.to_i #magic number 25 gives the best score of F
    end
    highest_timing = bounded_timing if bounded_timing > highest_timing
    output << "#{street_name} #{bounded_timing}"
  end
end

######## Output

puts "average_street_length = #{average_street_length}"
puts "average_incoming_streets = #{average_incoming_streets}"
puts "average_street_weight = #{average_street_weight}"
puts "max_street_weight = #{max_street_weight}"
puts "highest_timing = #{highest_timing}"

`mkdir -p outputs`
File.write("outputs/"+FILENAME.split('/').last+".output", output.join("\n"))

puts "FINISHED in #{(Time.now - start_time).to_f}"
puts
# puts `cat #{"outputs/"+FILENAME.split('/').last+".output"}`[0..100]