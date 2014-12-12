module Rcom
  class Topic
    attr_reader :node, :key

    def initialize(params)
      @node = params[:node]
      @key = params[:key]
    end

    def publish(message)
      begin
        node.publish(key, message.to_msgpack)
        return true
      rescue
        return nil
      end
    end

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
