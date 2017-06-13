### by bussealle
### validated ruby -v 2.3.1

require 'csv'

#### if you want to execute this program from editor
#### delete from here
raise "usage: arg1:<path to csv file>" unless ARGV.length == 1
raise "'#{ARGV[0]}' is not .csv file" unless ARGV[0].include?('.csv')
csv_file = ARGV[0]
#### to here
#csv_file = 'your csv'


data_file = "#{csv_file.match(/(.*)\..*/)[1]}.data"
names_file = "#{csv_file.match(/(.*)\..*/)[1]}.names"

puts "reading csv files..."
csv_data = CSV.read(csv_file)
param_name = csv_data[0]
raise "parameters not found in head of csv" if param_name.any? { |e| e=~/\A(-)?\d+(\.\d+)?\z/ }
puts "#{param_name.length} parameters detected!"
puts "--> #{param_name.join(", ")}"
output_hash = {}
param_name.each do |param|
  output_hash[param]=[]
end
csv_data.each_with_index do |csv_row, i|
  next if i==0
  csv_row.each_with_index do |value, j|
    next if value=='?' || value=='N/A'  || value.empty?
    # detect numeric value
    if value =~ /\A(-)?\d+(\.\d+)?\z/
      output_hash[param_name[j]] << 'continuous' if output_hash[param_name[j]].empty?

    # --------- add condition here ---------

    else
      output_hash[param_name[j]] << value unless output_hash[param_name[j]].any? { |e| e==value }
    end
  end
end

# write .data file
File.open(data_file, 'w:utf-8') do |data_f|
  File.open(csv_file, 'r:utf-8') do |csv_f|
    sline = csv_f.gets
    while sline = csv_f.gets do
      data_f.write(sline)
    end
  end
end
puts
puts "'#{data_file}' generated"
# write .names file
File.open(names_file, 'w:utf-8') do |file|
  file.write("<TARGET ATTRIBUTE>.\t| attribute containing class to be predicted\n\n")
  output_hash.each do |key, val|
    file.write("#{key}:\t#{val.join(',')}.\n")
  end
end
puts "'#{names_file}' generated"

puts
puts "done!"
puts "**** don't forget to edit '#{names_file}' for specifing your <TARGET ATTRIBUTE>"
