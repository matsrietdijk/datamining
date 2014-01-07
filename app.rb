require "csv"
require_relative "lib/r"
require_relative "lib/cmd"

file    = CMD.get_input "Path to file: ", type: :file, default: "data/restaurant.arff"
headers = CMD.parse_headers file
rows    = CMD.parse file
if File.read(file).include? "NUMERIC"
  group_column = CMD.get_input "Run group for column index (1-#{rows.first.length - 1}): ", type: :numeric, length: rows.first.length - 1
  R.group rows, group_column
else
  column  = CMD.get_input "Run ZeroR for column index (1-#{rows.first.length}): ", type: :numeric, length: rows.first.length, default: rows.first.length
  R.zero rows, column
  R.one rows
end
