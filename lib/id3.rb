module DecisionTree
  def self.id3 set, headers
    get_decision set
  end

  def self.get_decision set
    outcomes = {}
    columns  = []
    set.each do |row|
      value = row.pop.to_sym
      outcomes[ value ] = !outcomes[ value ] ? 1 : outcomes[ value ] + 1
      row.each_with_index do |item, column|
        c_value = item.to_sym
        columns[ column ] = {} unless columns[ column ]
        columns[ column ][ c_value ] = {} unless columns[ column ][ c_value ]
        columns[ column ][ c_value ][ value ] = !columns[ column ][ c_value ][ value ] ? 1 : columns[ column ][ c_value ][ value ] + 1
      end
    end

    gains = []
    outcome_total = (outcomes[ outcomes.keys[0] ] + outcomes[ outcomes.keys[1] ]).to_f
    entpropy = (outcomes[ outcomes.keys[0] ].to_f / outcome_total) + (outcomes[ outcomes.keys[1] ].to_f / outcome_total)
    columns.each_with_index do |values, column|
      # calculate gains
    end

    # return best column index
  end 
end