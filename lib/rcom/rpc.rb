module Rcom
  class Request
    attr_reader :node, :channel

    def initialize(params)
      @node = params[:node]
      @channel = params[:channel]
    end

    def method_missing(name, args)
      begin
        request = {
          id: SecureRandom.hex,
          method: name,
          args: args || ''
        }

        node.rpush(channel, request.to_msgpack)
        ch, response = node.brpop(request[:id], timeout=10)

        MessagePack.unpack(response, symbolize_keys: true)
      rescue
        return nil
      end
    end
  end

  class Response
    attr_reader :node, :channel, :server

    def initialize(params)
      @node = params[:node]
      @channel = params[:channel]
      @server = params[:server]
    end

    def serve
      begin
        loop do
          ch, request = node.brpop(channel)

          message = MessagePack.unpack(
            request,
            symbolize_keys: true
          )
          response = send_method(
            message[:method],
            message[:args]
          )

          node.rpush(message[:id], response.to_msgpack)
        end
      rescue
        sleep 1
        retry
      rescue Interrupt => _
      end
    end

    def send_method(method, args)
      begin
        server.send(method, args)
      rescue
        return nil
      end
    end
  end
end
