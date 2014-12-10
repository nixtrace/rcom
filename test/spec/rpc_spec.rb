require_relative './_init'

describe 'Rpc' do
  before do
    ENV['LOCAL'] = 'redis://localhost'
    @node = Rcom::Node.new('local').connect
    @service = Rcom::Rpc.new(node: @node, service: 'auth')
  end

  it 'represents a remote procedure call' do
    @service.must_be_instance_of Rcom::Rpc
  end

  it 'returns nil if the request cannot be processed' do
    service = Rcom::Rpc.new(node: @node, service: 'auth')
    service.request(method: 'nonexistent').must_equal nil
  end

  it 'works in a request/response scenario' do
    user_key = 'xxxccc'
    response = ''
    publisher = 'bundle exec ruby test/bin/rpc_publisher.rb'
    consumer = 'bundle exec ruby test/bin/rpc_consumer.rb'

    # Spawn consumer and wait for requests.
    consumer_pid = spawn(consumer)
    sleep 1

    # Spawn a request and record stdout,
    # then kill both consumer and publisher.
    Open3.popen3(publisher) do |stdin, stdout, stderr, thr|
      response = stdout.gets
      Process.kill('INT', thr.pid)
    end
    Process.kill('INT', consumer_pid)

    eval(response.chomp).must_equal user_key
  end
end
