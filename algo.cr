start_time = Time.utc

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

class Data
  @@c : Int8 = 0 #class (across all instances)
  @d : Int8 = 1  #instance variable
  
  def initialize(@a : Int8, @b : Int8)
  end
  
  def doSomething
  end
end

simulation_length = 0
intersection_count = 0
street_count = 0
car_count = 0
score_per_success = 0

intersections = [] of Int8
streets = [] of Hash(String => Int32|String) #id => list of characteristics
cars = []



######## File Read and Parse

index = 0
File.each_line(FILENAME) do |line|
  line_parts = line.split(' ')
  work_channel.send line_parts
  if index == 0
    # _count = line_parts[0].to_i
    # teams[2] = line_parts[1].to_i
    # teams[3] = line_parts[2].to_i
    # teams[4] = line_parts[3].to_i
  else
    next if line.blank?
    # pizzas[index - 1] = line_parts[1..-1]
  end
  index += 1
end
# file = File.open(FILENAME)

# puts File.open(FILENAME).read_line

######## Algorithm

working_space_data = data.clone

######## Output

output = [] of String

require "file_utils"
FileUtils.mkdir_p("outputs")
File.write("outputs/"+FILENAME.split('/').last+".output", output.reverse.join('\n'))

results = [] of String

puts "FINISHED in #{(Time.utc - start_time).to_f}"