module I19::Commands
  class Update
    def self.call(*args)
      self.new(*args).call
    end

    attr_accessor :path
    def initialize(path)
      @path = path
    end

    def call
      puts path
    end
  end
end
