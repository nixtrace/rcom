module Rcom
  class Rpc
    attr_reader :node, :service

    def initialize(params)
      @node = params[:node]
      @service = params[:service]
    end

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

  class Router
    attr_accessor :message, :reply

    def initialize(message)
      @message = message
    end

    def on(route)
      return nil unless message[:route] == route
      yield message[:args]
    end
  end
end
