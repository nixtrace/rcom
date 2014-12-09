require_relative './_init'

describe 'Rpc' do
  before do
    ENV['LOCAL'] = 'redis://localhost'
    @node = Rcom::Node.new('local').connect
  end

  it 'represents a remote procedure call' do
    service = Rcom::Rpc.new(node: @node, service: 'auth')
    service.must_be_instance_of Rcom::Rpc
  end

  it 'works in a request/response scenario' do
    user_key = 'xxxccc'
    response = ''
    publisher = 'bundle exec ruby test/bin/rpc_publisher.rb'
    consumer = 'bundle exec ruby test/bin/rpc_consumer.rb'

    # Start the consumer, wait for it to be up,
    # start the publisher and wait for the message
    # on the consumer side. Process, then kill
    # the long-running consumer.

    consumer_pid = spawn(consumer)
    sleep 1

    Open3.popen3(publisher) do |stdin, stdout, stderr, wait_thr|
      response = stdout.gets
      Process.kill('INT', wait_thr.pid)
    end

    Process.kill('INT', consumer_pid)

    eval(response.chomp).must_equal user_key
  end
end
