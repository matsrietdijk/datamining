require "csv"
require "pry"
require_relative "lib/id3"
require_relative "lib/cmd"

file    = CMD.get_input "Path to file: ", type: :file, default: "data/restaurant_test.arff"
train   = CMD.get_input "Path to train file: ", type: :file, default: "data/restaurant.arff"
headers = CMD.parse_headers file
columns = headers.map{|k, v| k}

# Remove the last header from the columns.
columns.pop
# Make the last yes or no a 1 or 0.
rows    = CMD.parse(file).map{|line| (line.last == "yes" ? 0 : 1); line }
train_rows = CMD.parse(train).map{|line| (line.last == "yes" ? 0 : 1); line }

# Instantiate the tree, and train it based on the data (set default to '1')
dec_tree = ID3::Tree.new(columns, train_rows, 1)
dec_tree.train

# Let the tree predict the output and compare it to the given value
rows.each { |t| predict = dec_tree.predict(t); puts "Voorspeld: #{predict} ... Gegeven: #{t.last}"; }

# Graph the tree, save to 'tree.png'
dec_tree.graph("tree")