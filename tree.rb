require "csv"
require_relative "lib/id3"
require_relative "lib/cmd"

file    = CMD.get_input "Path to file: ", type: :file, default: "data/restaurant.arff"
headers = CMD.parse_headers file
dataset = CMD.parse file

DecisionTree.id3 dataset, headers