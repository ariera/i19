module I19
  class Key
    class SourceOcurrence
      attr_accessor :src_path, :pos, :line_num, :line_pos, :line
      def initialize(args)
        @src_path = args[:src_path]
        @pos      = args[:pos]
        @line_num = args[:line_num]
        @line_pos = args[:line_pos]
        @line     = args[:line]
      end

      def short_path
        src_path.split("/").last + ":#{line_num}"
      end

      def long_path
        "#{src_path}:#{line_num}"
      end
    end

    class InconsistentDefaults < StandardError
      def initialize(key, defaults, source_occurrences)
        @key, @defaults, @source_occurrences = key, defaults, source_occurrences
      end

      def to_str
        "\n
        Inconsistent Defaults for:
          '#{@key}'
        Defaults:
          [#{@defaults.join(",")}]
        Source Files:
          #{@source_occurrences.map(&:long_path).join("\n\t  ")}
        "
      end
    end
    extend ActiveModel::Naming
    include ActiveModel::Validations

    validate :key_can_not_be_interpolated

    attr_accessor :key, :default, :source_occurrences
    alias_method :value, :default
    def initialize(args)
      @key = args[:key]
      @source_occurrences = Array(args[:source_occurrences]).map{|sc| SourceOcurrence.new(sc)}
      @defaults = Array(args[:defaults]).compact.uniq
      raise InconsistentDefaults.new(@key, @defaults, @source_occurrences) if @defaults.length > 1

      @default  = clean_default(@defaults.first)
    end

    def to_row
      [key, default, source_occurrences.map(&:short_path)]
    end

    private
    def key_can_not_be_interpolated
      if key.match(%r[#\{.*?\}])
        errors.add(:key, "'#{key}' looks like a interpolated string. Sorry, no support for that yet")
      end
    end

    def clean_default(str)
      return str if str.blank?
      str[0]  = '' if ["'", '"'].include?(str[0])
      str[-1] = '' if ["'", '"'].include?(str[-1])
      str.force_encoding("UTF-8")
      str
    end
  end
end
