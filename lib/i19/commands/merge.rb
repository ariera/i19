require 'terminal-table'
module I19
  module Commands
    class Merge
      def self.call(*args)
        self.new(*args).call
      end

      attr_accessor :locales_path
      def initialize(locales_path)
        @locales_path = locales_path
      end

      def call
        Merger.new(locales).call
      end

      private
      def locales
        @locales ||= I19::Locales.new
      end
    end
  end
end
