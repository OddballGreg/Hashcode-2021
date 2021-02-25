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
streets_by_id = {} #id => list of characteristics
streets_by_name = {} #name => list of characteristics
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
    
    streets_by_id[index - 1] = street
    streets_by_name[street_details[2]] = street
  else  # After initial line and all roads, read cars
    next if line.size.zero? #no blank lines in file
    car = {
      number_of_streets: line_parts[0],
      path: line_parts[1..-1],
      path_length: line_parts[1..-1].sum{|street_name| streets_by_name[street_name][:seconds]}
    }
    car_id = index - street_count - 1
    cars[car_id] = car
    intersections[streets_by_name[line_parts[1]][:ei]][:cars] << car_id
    car[:path].each{|street_name| streets_by_name[street_name][:weight] += 1 }
  end
end


######## Algorithm

current_cars = cars.reject{|id, car| car[:path_length] > simulation_length} #todo, make fasta

# simulation_length.times do |time|
#   current_cars.each do |car|
#     # current street is car[:path][0]
#     # current street is car[:path][1] = amsterdam. What is the intersection? Travel time for amsterdam? 
#     car[:path][1..-1]
#   end
# end
output = []

traveled_roads = current_cars.map{|id, car| car[:path]}.flatten.uniq
important_intersections = traveled_roads.map do |road|
  inter_id = streets_by_name[road][:ei]
  { inter_id => intersections[inter_id] }
end.reduce(&:merge)

output << important_intersections.size.to_s
important_intersections.each do |k,v|
  output << k
  output << v[:streets].size
  v[:streets].each do |street_name|
    output << "#{street_name} #{[1, [(streets_by_name[street_name][:weight] / v[:streets].length), simulation_length - 1].min].max.to_i}"
  end
end

######## Output

`mkdir -p outputs`
# File.write("outputs/"+FILENAME.split('/').last+".output", output.reverse.join("\n"))
File.write("outputs/"+FILENAME.split('/').last+".output", output.join("\n"))

puts "FINISHED in #{(Time.now - start_time).to_f}"
puts
puts `cat #{"outputs/"+FILENAME.split('/').last+".output"}`[0..100]