module I19
  module Commands

    class UnmergedLocalesError < StandardError
      def initialize
        super("There are unmerged locale files. Please merge them before (run: `i19 help merge`)")
      end
    end

    class UnspecifiedDefaultLocaleError < ArgumentError
      def initialize
        super("Please specify the default locale")
      end
    end

    class DefaultLocaleNotFoundError < StandardError
      def initialize
        super("default locale not found")
      end
    end

    class LocalesNotFoundError < StandardError
      def initialize
        super("locales not found")
      end
    end

  end
end
