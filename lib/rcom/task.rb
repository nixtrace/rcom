module Rcom
  class Task
    attr_reader :node, :channel

    def initialize(params)
      @node = params[:node]
      @channel = params[:channel]
    end

    def publish(message)
      begin
        node.lpush(channel, message.to_msgpack)
        return true
      rescue
        return nil
      end
    end

    def subscribe
      begin
        loop do
          ch, request = node.brpop(channel)
          message = MessagePack.unpack(
            request,
            symbolize_keys: true
          )
          yield message
        end
      rescue Interrupt => _
      end
    end
  end
end
