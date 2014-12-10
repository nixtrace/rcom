module Rcom
  # Implements pub/sub over topics.
  class Topic
    attr_reader :node, :key

    # @param params [Hash]
    # @option params :node [Rcom::Node]
    # @option params :key [String] Example: 'services'
    def initialize(params)
      @node = params[:node]
      @key = params[:key]
    end

    # @param message [Hash]
    # @return [true, nil] True if the message can be sent,
    # or nil if it can't be sent.
    def publish(message)
      begin
        node.publish(key, message.to_msgpack)
        return true
      rescue
        return nil
      end
    end

    # @yieldparam message [Hash] the message received.
    def subscribe
      begin
        node.subscribe(key) do |on|
          on.message do |channel, message|
            message = MessagePack.unpack(
              message,
              symbolize_keys: true
            )
            yield message
          end
        end
      rescue Interrupt => _
      end
    end
  end
end
