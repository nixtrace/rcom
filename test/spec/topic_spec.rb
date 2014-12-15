require_relative './_init'

describe 'Topic' do
  before do
    ENV['LOCAL'] = 'redis://localhost'
    @node = Rcom::Node.new('local').connect
    @topic = Rcom::Topic.new(node: @node, channel: 'users')
  end

  it 'represents a Topic' do
    @topic.must_be_instance_of Rcom::Topic
  end

  it 'can publish a message' do
    message = {
      id: 1,
      key: 'xxxccc'
    }
    @topic.publish(message).must_equal true
  end

  it 'can subscribe to a channel and receive a message' do
    original_message = {
      id: 1,
      key: 'xxxccc'
    }
    reader, writer = IO.pipe

    @subscriber = fork {
      @topic.subscribe do |message|
        writer.write message
      end
    }
    Process.detach @subscriber
    sleep 1

    @topic.publish(original_message)
    sleep 1

    Process.kill('INT', @subscriber)

    writer.close
    eval(reader.read).must_equal original_message
    reader.close
  end
end
