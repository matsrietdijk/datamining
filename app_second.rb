require "csv"
require_relative "lib/likelihood"
require_relative "lib/cmd"

file   = CMD.get_input "Path to file: ", type: :file, default: "data/restaurant.arff"
rows   = CMD.parse file

prob   = Likelihood.calculate_probabilities(rows)
record = Likelihood.get_record
chance = Likelihood.naive_bayes(record, prob)