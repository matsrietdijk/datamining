module CMD
  COLORS = {
    white: "\e[0m",
    green: "\e[32m",
    red: "\e[31m",
  }

  def self.w line, options = {}
    color = options[:color] || :white
    options[:nl] = true if options[:nl].nil?

    $stdout.write "#{COLORS[color]}#{line.to_s}#{COLORS[:white]}"
    $stdout.write "\n" if options[:nl]
  end

  def self.parse file
    rows = []
    CSV.parse(File.read(file).gsub(/.*@data/m, '').chomp) do |row|
      row.map!(&:strip)
      rows << row if !row.empty?
    end
    rows
  end

  def self.parse_headers file
    headers = {}
    File.read(file).gsub(/@data.*/m, '\1').chomp.each_line do |line|
      line.chomp!
      next unless line.include? "@attribute"
      parts = line.split
      headers[ parts[1].downcase.to_sym ] = parts[2].gsub(/\{(.*)\}/, '\1').split(',')
    end
    headers
  end

  def self.get_input query, options = {}
    type = options[:type]
    length = options[:length] || false
    default = options[:default] || false
    allowed = options[:in] || false

    query = "#{query} (#{allowed.join('/')}) " if allowed
    query = "#{query}(#{default}) " if default
    w query, nl: false
    input = gets.strip
    input = default if input.empty?
    case type
    when :file
      while !File.exist? input
        input = faulty_input "File doesn't exist", query, default
      end
    when :numeric
      if length
        while length.to_i < input.to_i
          input = faulty_input "Invalid column index (#{input})", query, default
        end
      end
      input = input.to_i
    when :boolean
      input = !!input
    when :string
      if allowed
        while !check_input(input, allowed)
          input = faulty_input "Invalid value, not in allowed values [#{allowed.join(', ')}]", query, default
        end
      end
    end
    input
  end

  def self.check_input input, allowed_values
    allowed_values.include?(input)
  end

  def self.faulty_input message, query, default
    w message, color: :red
    w query, nl: false
    input = gets.strip
    input = default if input.empty? && default
    input
  end
end