require "csv"
require "pry"
require_relative "lib/id3"
require_relative "lib/cmd"

file   = CMD.get_input "Path to train file: ", type: :file, default: "data/restaurant.arff"
headers = CMD.parse_headers file
columns = headers.map{|k, v| k}

# Remove the last header from the columns.
columns.pop
# Make the last yes or no a 1 or 0.
rows = CMD.parse(file).map{|line| (line.last == "yes" ? 0 : 1); line }

# Instantiate the tree, and train it based on the data (set default to '1')
dec_tree = ID3::Tree.new(columns, rows, 1)
dec_tree.id3

# Graph the tree, save to 'tree.png'
dec_tree.graph("tree")
CMD.w "Wrote tree to tree.png", color: :green