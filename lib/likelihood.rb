module Likelihood

  def self.calculate_probabilities rows, headers
    numerics = find_numerics(rows, headers)
    results  = count_values(rows, numerics)

    likelihoods = {}
    results.each_with_index do |column, index|
      likelihoods[ index ] = {}
      if numerics.include?(index)
        likelihoods[ index ][ :type ]            = :numeric
        likelihoods[ index ][ :yes ] = {}
        likelihoods[ index ][ :yes ][ :average ] = column[ :yes ].mean
        likelihoods[ index ][ :yes ][ :sd ]      = Math.sqrt(column[ :yes ].var)
        likelihoods[ index ][ :no ] = {}
        likelihoods[ index ][ :no ][ :average ]  = column[ :no ].mean
        likelihoods[ index ][ :no ][ :sd ]       = Math.sqrt(column[ :no ].var)
      else
        likelihoods[ index ][ :type ] = :nominal
        yes = 0
        no  = 0
        column.each do |key, attr|
          yes += attr[:yes]
          no  += attr[:no]
        end
        if results.length - 1 == index
          likelihoods[ index ][ :yes ] = (yes.to_f / rows.length.to_f).round(3)
          likelihoods[ index ][ :no ] = (no.to_f / rows.length.to_f).round(3)
        else
          column.each do |key, attr|
            yess = (attr[:yes].to_f / yes.to_f).round(3)
            nos  = (attr[:no].to_f / no.to_f).round(3)
            likelihoods[ index ][ key ] = { yes: yess, no: nos}
          end
        end
      end
    end
    likelihoods
  end

  def self.count_values rows, numerics
    results = []
    rows.each_with_index do |row, index|
      match = row.last
      match_symbol = match.gsub(/\s+/, "_").downcase.to_sym
      row.each_with_index do |v, index|
        symbol = v.gsub(/\s+/, "_").downcase.to_sym
        results[ index ] = {} if results[ index ].nil?
        unless numerics.include?(index)
          results[ index ][ symbol ] = { yes: 0, no: 0} if results[ index ][ symbol ].nil?
          results[ index ][ symbol ][ match_symbol ] += 1
        else
          results[ index ][ :yes ] = [] if results[ index ][ :yes ].nil?
          results[ index ][ :no ] = [] if results[ index ][ :no ].nil?
          symbol = row.last.to_sym
          results[ index ][ symbol ] << v.to_f
        end
      end
    end
    results
  end

  def self.find_numerics rows, headers
    numerics = []
    headers.each_with_index do |(key, value), index|
      numerics << index if value == :numeric
    end
    numerics
  end

  def self.get_record headers
    records = {}
    headers.each_with_index do |(header, possibilities), index|
      records[ index ] = {}
      if possibilities == :numeric
        records[ index ][ :value ] = CMD.get_input header.to_s.capitalize, type: :numeric
        records[ index ][ :type ]  = :numeric
      else
        records[ index ][ :value ] = CMD.get_input header.to_s.capitalize, type: :string, in: possibilities
        records[ index ][ :type ]  = :nominal
      end
    end
    records
  end

  def self.naive_bayes record, prob
    chance = {yes: 1.0, no: 1.0} # default val
    record.each do |column, attr|
      if column.to_i == record.keys.last.to_i
        chance[:yes] *= prob[ column.to_i ][ :yes ].to_f
        chance[:no]  *= prob[ column.to_i ][ :no ].to_f
      elsif attr[ :type ] == :numeric
        avg_yes = prob[ column.to_i ][ :yes ][ :average ]
        sd_yes  = prob[ column.to_i ][ :yes ][ :sd ]
        avg_no = prob[ column.to_i ][ :no ][ :average ]
        sd_no  = prob[ column.to_i ][ :no ][ :sd ]
        chance[:yes] *= density(attr[ :value ], avg_yes, sd_yes)
        chance[:no] *= density(attr[ :value ], avg_no, sd_no)
      else
        chance[:yes] *= prob[ column.to_i ][ attr[ :value ].to_sym ][ :yes ].to_f
        chance[:no]  *= prob[ column.to_i ][ attr[ :value ].to_sym ][ :no ].to_f
      end
    end
    CMD.w "Chance for yes: #{(chance[ :yes ] * 100.0 / (chance[:yes] + chance[:no])).round(2)}%"
    CMD.w "Chance for no: #{(chance[ :no ] * 100.0 / (chance[:yes] + chance[:no])).round(2)}%"
  end

  def self.density value, mean, sd
    exponent = -((value - mean) / sd)**2
    (Math.exp(exponent) / (sd * Math.sqrt(2 * Math::PI)))
  end
end

class Array
  def sum
    total = 0.0
    each do |x|
      total += x
    end
    total
  end

  def mean
    sum / size
  end

  def var
    inject(0.0){|total, x| total += (x.to_f - mean)**2} / (size - 1)
  end
end