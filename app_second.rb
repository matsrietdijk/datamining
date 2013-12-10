require "csv"
require_relative "lib/likelihood"
require_relative "lib/cmd"

file   = CMD.get_input "Path to file: ", type: :file, default: "data/restaurant_num.arff"
headers = CMD.parse_headers file
rows   = CMD.parse file

prob   = Likelihood.calculate_probabilities(rows, headers)
record = Likelihood.get_record headers
chance = Likelihood.naive_bayes(record, prob)