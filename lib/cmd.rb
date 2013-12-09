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

  def self.get_input query, options = {}
    type = options[:type]
    length = options[:length] || false
    default = options[:default] || false

    query = "#{query}(#{default}) " if default
    w query, nl: false
    input = gets.strip
    input = default if input.empty?
    case type
    when :file
      while !File.exist? input
        w "File doesn't exist", color: :red
        w query, nl: false
        input = gets.strip
        input = default if input.empty?
      end
    when :numeric
      if length
        while length.to_i < input.to_i
          w "Invalid column index (#{input})", color: :red
          w query, nl: false
          input = gets.strip
          input = default if input.empty?
        end
      end
      input = input.to_i
    end
    input
  end
end