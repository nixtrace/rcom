module Rcom
  class Topic
    attr_reader :node, :channel

    def initialize(params)
      @node = params[:node]
      @key = params[:channel]
    end

    def publish(message)
      begin
        node.publish(channel, message.to_msgpack)
        return true
      rescue
        return nil
      end
    end

    def subscribe
      begin
        node.subscribe(channel) do |on|
          on.message do |channel, message|
            message = MessagePack.unpack(
              message,
              symbolize_keys: true
            )
            yield message
          end
        end
      rescue
        sleep 1
        retry
      rescue Interrupt => _
      end
    end
  end
end
