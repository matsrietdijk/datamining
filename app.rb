require "csv"
require_relative "lib/r"
require_relative "lib/cmd"

file   = CMD.get_input "Path to file: ", type: :file, default: "data/restaurant.arff"
rows   = CMD.parse file
column = CMD.get_input "Run ZeroR for column index: ", type: :numeric, length: rows.first.length, default: rows.first.length

R.zero rows, column
R.one rows