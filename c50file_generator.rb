### by bussealle
### validated ruby -v 2.3.1

require 'csv'

#### if you want to execute this program from editor
#### delete from here
raise "\nusage:\targ1:<path to csv file>\t<option>\n\t\toption: -t <the percentage of "\
"samples for test>" unless ARGV.length == 1 || (ARGV.length == 3 && ARGV[1] == '-t')
raise "'#{ARGV[0]}' is not .csv file" unless ARGV[0].include?('.csv')
csv_file = ARGV[0]
test_percent = 0
test_percent = ARGV[2].to_i if ARGV.length == 3
raise "-t <the percentage should be in 0-100>" unless (0..100).include?(test_percent)
#### to here
#csv_file = 'your csv'
#test_percent = 0


data_file = "#{csv_file.match(/(.*)\..*/)[1]}.data"
test_file = "#{csv_file.match(/(.*)\..*/)[1]}.test"
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
threshold = csv_data.length * test_percent/100
File.open(data_file, 'w:utf-8') do |data_f|
  File.open(test_file, 'w:utf-8') do |test_f|
    csv_data.delete_at(0)
    csv_data.shuffle!
    csv_data.each_with_index do |data,i|
      if i < threshold
        test_f.write("#{data.join(',')}\n")
      else
        data_f.write("#{data.join(',')}\n")
      end
    end
  end
end
File.delete(test_file) if threshold==0
puts
puts "'#{data_file}' generated"
puts "'#{test_file}' generated" unless threshold==0
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
