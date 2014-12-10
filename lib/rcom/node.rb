module Rcom
  # A node represents a Redis server and has an uri.
  class Node
    # @return [String]
    attr_reader :uri

    # @param uri [String] Example: 'local'
    # @raise [ArgumentError] uri is not in .env.
    def initialize(uri)
      raise ArgumentError unless ENV[uri.upcase]
      @uri = ENV[uri.upcase]
    end

    # Connects to Redis.
    # @return [Redis]
    def connect
      Redis.new(url: uri)
    end
  end
end
