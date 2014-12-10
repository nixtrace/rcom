module Rcom
  # Implements tasks and queues.
  class Task
    attr_reader :node, :queue

    # @param params [Hash]
    # @option params :node [Rcom::Node]
    # @option params :queue [String] Example: 'messages'
    def initialize(params)
      @node = params[:node]
      @queue = params[:queue]
    end

    # @param message [Hash]
    # @return [true, nil] True if the message can be queued, otherwise nil.
    def publish(message)
      begin
        node.lpush(queue, message.to_msgpack)
        return true
      rescue
        return nil
      end
    end

    # @yieldparam message [Hash] the message received.
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
