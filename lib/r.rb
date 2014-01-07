require_relative "cmd"

module R
  def self.zero rows, column
    CMD.w "ZeroR"
    CMD.w "Using column index: #{column}"
    CMD.w "Total instances: #{rows.length}"

    values = {}
    rows.each do |row|
      symbol = row[ column - 1 ].gsub(/\s+/, "_").downcase.to_sym
      if values[ symbol ].nil?
        values[ symbol ] = 1
      else
        values[ symbol ] += 1
      end
    end

    values = Hash[ values.sort_by { |k, v| v }.reverse ]
    last_value = nil
    values.each do |k, v|
      break if !last_value.nil? && last_value > v
      last_value = v
      CMD.w "#{k.to_s.gsub(/_/, "\s")}:\t#{v}\t#{(v.to_f * 100.0 / rows.length.to_f).round(2)}%", color: :green
    end
  end

  def self.one rows
    CMD.w "OneR"
    results = []
    rows.each do |row|
      match = row.last
      match_symbol = match.gsub(/\s+/, "_").downcase.to_sym
      row.each_with_index do |v, index|
        break if index == row.length - 1
        symbol = v.gsub(/\s+/, "_").downcase.to_sym
        results[ index ] = {} if results[ index ].nil?
        results[ index ][ symbol ] = {} if results[ index ][ symbol ].nil?
        results[ index ][ symbol ][ match_symbol ] = 0 if results[ index ][ symbol ][ match_symbol ].nil?
        results[ index ][ symbol ][ match_symbol ] += 1
      end
    end

    best_first = {}
    best_value = nil
    results.each_with_index do |row, index|
      error = 0
      row.each do |key, value|
        error += value.values.sort.first if value.length > 1
      end
      percentage = (error.to_f * 100.0 / rows.first.length.to_f).round(2)
      best_first[ index.to_s.to_sym ] = percentage
      best_value = percentage if best_value.nil? || percentage < best_value
    end

    Hash[ best_first.sort_by { |k, v| v } ].each do |k, v|
      color = (v == best_value) ? :green : :white
      index = k.to_s.to_i
      CMD.w "Column #{index + 1}:\t#{(100.0 - v).round(2)}%", color: color
      if v == best_value
        results[ index ].each do |value, counts|
          column_value = counts.sort_by { |k, v| v }.reverse.first
          CMD.w "  #{value.to_s}\t-> #{column_value[0].to_s}\t(#{column_value[1]})", color: color
        end
      end
    end
  end

  def self.group rows, column, options = {}
  end
end