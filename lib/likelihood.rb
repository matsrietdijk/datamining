module Likelihood

  def self.calculate_probabilities rows
    results = []
    rows.each do |row|
      match = row.last
      match_symbol = match.gsub(/\s+/, "_").downcase.to_sym

      row.each_with_index do |v, index|
        symbol = v.gsub(/\s+/, "_").downcase.to_sym
        results[ index ] = {} if results[ index ].nil?
        results[ index ][ symbol ] = { yes: 0, no: 0} if results[ index ][ symbol ].nil?
        results[ index ][ symbol ][ match_symbol ] += 1
      end
    end

    likelihoods = {}
    results.each_with_index do |column, index|
      yes = 0
      no  = 0
      column.each_with_index do |(key, attr), count|
        yes += attr[:yes]
        no  += attr[:no]
      end
      likelihoods[ index ] = {}
      if results.length - 1 == index
        likelihoods[ index ][ :yes ] = (yes.to_f / rows.length.to_f).round(3)
        likelihoods[ index ][ :no ] = (no.to_f / rows.length.to_f).round(3)
      else
        column.each do |key, attr|
          if attr[:yes] == 0 || attr[:no] == 0
            attr[:yes] += 1
            attr[:no]  += 1
            yes += 1
            no  += 1
          end
          yess = (attr[:yes].to_f / yes.to_f).round(3)
          nos  = (attr[:no].to_f / no.to_f).round(3)
          likelihoods[ index ][ key ] = { yes: yess, no: nos}
        end
      end
    end
    likelihoods
  end

  def self.get_record headers
    records = {}
    headers.each_with_index do |(header, possibilities), index|
      records[ index ] = CMD.get_input header.to_s.capitalize, type: :string, in: possibilities
    end
    records
  end

  def self.naive_bayes record, prob
    chance = {yes: 1.0, no: 1.0} # default val
    record.each do |column, attr|
      if column.to_i == record.keys.last.to_i
        chance[:yes] *= prob[ column.to_i ][ :yes ].to_f
        chance[:no]  *= prob[ column.to_i ][ :no ].to_f
      else
        chance[:yes] *= prob[ column.to_i ][ attr.to_sym ][ :yes ].to_f
        chance[:no]  *= prob[ column.to_i ][ attr.to_sym ][ :no ].to_f
      end
    end
    CMD.w "Chance for yes: #{(chance[ :yes ] * 100.0 / (chance[:yes] + chance[:no])).round(2)}%"
    CMD.w "Chance for no: #{(chance[ :no ] * 100.0 / (chance[:yes] + chance[:no])).round(2)}%"
  end
end

class Array
  def sum
    self.inject{|sum, x| sum + x}
  end
end