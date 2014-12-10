module Rcom
  # Rpc implements the request/response pattern.
  class Rpc
    # @return [Rcom::Node]
    attr_reader :node
    # @return [String]
    attr_reader :service

    # @param params [Hash]
    # @option params :node [Rcom::Node] Example: Rcom::Node.new('local').connect
    # @option params :service [String] Example: 'auth'
    def initialize(params)
      @node = params[:node]
      @service = params[:service]
    end

    # @param params [Hash]
    # @option params :route [String] Example: 'users.key'
    # @option params :args Example: 1
    # @return [reply, nil] Returns the reply or nil if the
    # request can't be processed.
    def request(params)
      begin
        request = {
          id: SecureRandom.hex,
          route: params[:route],
          args: params[:args] || ''
        }

        node.rpush(service, request.to_msgpack)
        ch, response = node.brpop(request[:id], timeout=10)

        MessagePack.unpack(
          response,
          symbolize_keys: true
        )
      rescue
        return nil
      end
    end

    # Subscribe to the service and listen to requests.
    # @yieldparam router [Rcom::Router] A router to match the request.
    def subscribe
      begin
        loop do
          ch, request = node.brpop(service)

          message = MessagePack.unpack(
            request,
            symbolize_keys: true
          )
          router = Rcom::Router.new(message)

          yield router

          node.rpush(message[:id], router.reply.to_msgpack)
        end
      rescue Interrupt => _
      end
    end
  end

  # A router can match on a particular route.
  class Router
    attr_accessor :message, :reply

    # @param message [Hash] The message received with the request.
    def initialize(message)
      @message = message
    end

    # @yieldparam args
    def on(route)
      return nil unless message[:route] == route
      yield message[:args]
    end
  end
end
