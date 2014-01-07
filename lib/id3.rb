class Object
  def save_to_file(filename)
    File.open(filename, 'w+' ) { |f| f << Marshal.dump(self) }
  end

  def self.load_from_file(filename)
    Marshal.load( File.read( filename ) )
  end
end

class Array
  def classification; collect { |v| v.last }; end

  # calculate information entropy
  def entropy
    return 0 if empty?

    info = {}
    total = 0
    each {|i| info[i] = !info[i] ? 1 : (info[i] + 1); total += 1}

    result = 0
    info.each do |symbol, count|
      result += -count.to_f/total*Math.log(count.to_f/total)/Math.log(2.0) if (count > 0)
    end
    result
  end
end

module ID3
  Node = Struct.new(:attribute, :threshold, :gain)

  class Tree
    def initialize(attributes, data, default)
      @used, @tree = {}, {}
      @data, @attributes, @default = data, attributes, default
    end

    def id3(data=@data, attributes=@attributes, default=@default)
      attributes = attributes.map {|e| e.to_s}
      initialize(attributes, data, default)

      # Remove samples with same attributes leaving most common classification
      data2 = data.inject({}) {|hash, d| hash[d.slice(0..-2)] ||= Hash.new(0); hash[d.slice(0..-2)][d.last] += 1; hash }.map{|key,val| key + [val.sort_by{ |k, v| v }.last.first]}

      @tree = id3_calculate(data2, attributes, default)
    end

    def id3_calculate(data, attributes, default, used={})
      return default if data.empty?

      # return classification if all examples have the same classification
      return data.first.last if data.classification.uniq.size == 1

      # Choose best attribute:
      # 1. enumerate all attributes
      # 2. Pick best attribute
      # 3. If attributes all score the same, then pick a random one.
      performance = attributes.collect { |attribute| proc{|a,b,c| id3_perform(a,b,c)}.call(data, attributes, attribute) }
      max = performance.max { |a,b| a[0] <=> b[0] }
      min = performance.min { |a,b| a[0] <=> b[0] }
      max = performance.shuffle.first if max[0] == min[0]
      best = Node.new(attributes[performance.index(max)], max[1], max[0])
      best.threshold = nil
      @used.has_key?(best.attribute) ? @used[best.attribute] += [best.threshold] : @used[best.attribute] = [best.threshold]
      tree, l = {best => {}}, ['>=', '<']

      fitness = proc{|a,b,c| id3_perform(a,b,c)}
      values = data.collect { |d| d[attributes.index(best.attribute)] }.uniq.sort
      partitions = values.collect { |val| data.select { |d| d[attributes.index(best.attribute)] == val } }
      partitions.each_with_index  { |examples, i|
        tree[best][values[i]] = id3_calculate(examples, attributes-[values[i]], (data.classification.mode rescue 0), &fitness)
      }

      tree
    end

    # ID3 for discrete label cases
    def id3_perform(data, attributes, attribute)
      values = data.collect { |d| d[attributes.index(attribute)] }.uniq.sort
      partitions = values.collect { |val| data.select { |d| d[attributes.index(attribute)] == val } }
      remainder = partitions.collect {|p| (p.size.to_f / data.size) * p.classification.entropy}.inject(0) {|i,s| s+=i }

      [data.classification.entropy - remainder, attributes.index(attribute)]
    end

    def graph(filename)
      require 'graphr'
      dgp = DotGraphPrinter.new(build_tree)
      dgp.write_to_file("#{filename}.png", "png")
    end

  private
    def descend(tree, test)
      attr = tree.to_a.first
      return @default if !attr
      return attr[1][test[@attributes.index(attr[0].attribute)]] if !attr[1][test[@attributes.index(attr[0].attribute)]].is_a?(Hash)
      return descend(attr[1][test[@attributes.index(attr[0].attribute)]],test)
    end

    def build_tree(tree = @tree)
      return [] unless tree.is_a?(Hash)
      return [["Always", @default]] if tree.empty?

      attr = tree.to_a.first

      links = attr[1].keys.collect do |key|
        parent_text = "#{attr[0].attribute}\n(#{attr[0].object_id})"
        if attr[1][key].is_a?(Hash) then
          child = attr[1][key].to_a.first[0]
          child_text = "#{child.attribute}\n(#{child.object_id})"
        else
          child = attr[1][key]
          child_text = "#{child}\n(#{child.to_s.clone.object_id})"
        end
        label_text = "#{key}"

        [parent_text, child_text, label_text]
      end
      attr[1].keys.each { |key| links += build_tree(attr[1][key]) }

      return links
    end
  end
end