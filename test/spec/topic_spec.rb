require_relative './_init'

describe 'Topic' do
  before do
    ENV['LOCAL'] = 'redis://localhost'
    @node = Rcom::Node.new('local').connect
  end

  it 'represents a Topic' do
    topic = Rcom::Topic.new(node: @node, key: 'users')
    topic.must_be_instance_of Rcom::Topic
  end

  it 'works in a pub/sub scenario' do
    message = {
      id: 1,
      key: 'xxxccc'
    }
    read_message = ''
    publisher = 'bundle exec ruby test/bin/topic_publisher.rb'
    subscriber = 'bundle exec ruby test/bin/topic_subscriber.rb'

    # Start the subscriber, wait for it to be up,
    # start the publisher and wait for the message
    # on the subscriber side. Then kill
    # the long-running subscriber.
    Open3.popen3(subscriber) do |stdin, stdout, stderr, wait_thr|
      sleep 1
      spawn(publisher)
      read_message = stdout.gets
      Process.kill('INT', wait_thr.pid)
    end

    output = eval read_message.chomp
    output.must_equal message
  end
end
