module Rcom
  class Node
    attr_reader :uri

    def initialize(uri)
      raise ArgumentError unless ENV[uri.upcase]
      @uri = ENV[uri.upcase]
    end

    def connect
      Redis.new(url: uri)
    end
  end
end
