module Rcom
  # Rpc implements the request/response pattern.
  class Request
    attr_reader :node, :service

    def initialize(params)
      @node = params[:node]
      @service = params[:service]
    end

    def method_missing(name, *args)
      begin
        request = {
          id: SecureRandom.hex,
          method: name,
          args: args || ''
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
  end

  class Response
    attr_reader :node, :service, :server

    def initialize(params)
      @node = params[:node]
      @service = params[:service]
      @server = params[:server]
    end

    def serve
      begin
        loop do
          ch, request = node.brpop(service)

          message = MessagePack.unpack(
            request,
            symbolize_keys: true
          )

          response = send_method(
            message[:method],
            *message[:args]
          )

          node.rpush(message[:id], response.to_msgpack)
        end
      rescue Interrupt => _
      end
    end

    def send_method(method, args)
      # begin
        server.send(method, args)
      # rescue
      #   return nil
      # end
    end
  end
end
