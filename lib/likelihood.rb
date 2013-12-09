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
      column.each do |key, attr|
        yes += attr[:yes]
        no  += attr[:no]
      end
      likelihoods[ index ] = {}
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
    likelihoods
  end

  def self.get_record
    alternative  = CMD.get_input "Alternative", type: :string, in: ["yes", "no"]
    bar          = CMD.get_input "Bar",         type: :string, in: ["yes", "no"]
    friday_sat   = CMD.get_input "FridaySat",   type: :string, in: ["yes", "no"]
    hunger       = CMD.get_input "Hunger",      type: :string, in: ["yes", "no"]
    pat          = CMD.get_input "Patat",       type: :string, in: ["some", "full", "none"]
    price        = CMD.get_input "Price",       type: :string, in: ["$", "$$", "$$$"]
    rain         = CMD.get_input "Rain",        type: :string, in: ["yes", "no"]
    res          = CMD.get_input "Res",         type: :string, in: ["yes", "no"]
    est          = CMD.get_input "Est",         type: :string, in: ["0-10", "10-30", "30-60", "60+"]
    type         = CMD.get_input "Type",        type: :string, in: ["burger", "french", "italian", "thai"]
    wait         = CMD.get_input "Wait",        type: :string, in: ["yes", "no"]

    {
      "0" => alternative,
      "1" => bar,
      "2" => friday_sat,
      "3" => hunger,
      "4" => pat,
      "5" => price,
      "6" => rain,
      "7" => res,
      "8" => est,
      "9" => type,
      "10" => wait,
    }
  end

  def self.naive_bayes record, prob
    chance = {yes: 1.0, no: 1.0} # default val
    record.each do |column, attr|
      if column == record.keys.last.to_s
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