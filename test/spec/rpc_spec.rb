require_relative './_init'

describe 'Request' do
  before do
    ENV['LOCAL'] = 'redis://localhost'
    @node = Rcom::Node.new('local').connect
    @auth = Rcom::Request.new(node: @node, channel: 'auth')
    @rpc_server = fork {
      class Server
        def get_key(params)
          return nil unless params[:user] == 1
          return 'xxxccc'
        end
      end
      auth = Rcom::Response.new(
        node: @node, 
        channel: 'auth',
        server: Server.new
      )
      auth.serve
    }
    Process.detach @rpc_server
  end

  it 'represents a request' do
    @auth.must_be_instance_of Rcom::Request
  end

  it 'returns nil if the request method is nonexistent' do
    @auth.get_nonexistent(1).must_equal nil
  end

  it 'returns the right key if the server method exists' do
    @auth.get_key(user: 1).must_equal 'xxxccc'
  end

  # it 'works in a request/response scenario' do
  #   user_key = 'xxxccc'
  #   response = ''
  #   publisher = 'bundle exec ruby test/bin/rpc_publisher.rb'
  #   consumer = 'bundle exec ruby test/bin/rpc_consumer.rb'

  #   # Spawn consumer and wait for requests.
  #   consumer_pid = spawn(consumer)
  #   sleep 1

  #   # Spawn a request and record stdout,
  #   # then kill both consumer and publisher.
  #   Open3.popen3(publisher) do |stdin, stdout, stderr, thr|
  #     response = stdout.gets
  #     Process.kill('INT', thr.pid)
  #   end
  #   Process.kill('INT', consumer_pid)

  #   eval(response.chomp).must_equal user_key
  # end
  after do
    Process.kill('INT', @rpc_server)
  end
end
