module Rcom
  class Task
    attr_reader :node, :queue

    def initialize(args)
      @node = args[:node]
      @queue = args[:queue]
    end

    def publish(message)
      begin
        node.lpush(queue, message.to_msgpack)
        return true
      rescue
        return nil
      end
    end

    def subscribe
      begin
        loop do
          ch, request = node.brpop(queue)
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
