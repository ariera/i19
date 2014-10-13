class Key
  #TODO: give source_occurrences its own model
  #TODO: validate that all the defaults are the same or raise an error
  class InconsistentDefaults < StandardError
    def initialize(defaults, source_occurrences)
      @defaults, @source_occurrences = defaults, source_occurrences
    end

    def to_str
      %{
        Inconsistent Defaults:
        [#{@defaults.join(",")}]
        Source Files:
        #{@source_occurrences.join("\n\t")}
      }
    end
  end

  attr_accessor :key, :default, :source_occurrences
  def initialize(args)
    @key = args[:key]
    @source_occurrences = Array(args[:source_occurrences])
    @defaults = Array(args[:defaults]).compact.uniq
    raise InconsistentDefaults.new(@defaults, @source_occurrences) if @defaults.length > 1


    @default  = clean_default(@defaults.first)
  end

  def to_row
    [key, default]
  end

  def valid?
    true
  end

  private

  def clean_default(str)
    return str if str.blank?
    str[0]  = '' if ["'", '"'].include?(str[0])
    str[-1] = '' if ["'", '"'].include?(str[-1])
    str
  end
end
