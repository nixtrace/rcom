require_relative './_init'

describe 'Request' do
  before do
    ENV['LOCAL'] = 'redis://localhost'
    @node = Rcom::Node.new('local').connect
    @request = Rcom::Request.new(node: @node, channel: 'auth')
  end

  it 'represents a request' do
    @request.must_be_instance_of Rcom::Request
  end
end

describe 'Response' do
  before do
    ENV['LOCAL'] = 'redis://localhost'
    @node = Rcom::Node.new('local').connect
    @response = Rcom::Response.new(
      node: @node,
      channel: 'auth',
      server: nil
    )
  end

  it 'represents a response' do
    @response.must_be_instance_of Rcom::Response
  end
end

describe 'Request-Response' do
  before do
    ENV['LOCAL'] = 'redis://localhost'
    @node = Rcom::Node.new('local').connect

    @service = Rcom::Request.new(node: @node, channel: 'auth')

    @rpc_server = fork {
      class Server
        def get_key(params)
          user = params[:user]
          return nil unless user == 1
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
    sleep 1
  end

  it 'cannot request method that does not exists' do
    @service.get_nonexistent(1).must_equal nil
  end

  it 'can request a method with the correct hash param' do
    @service.get_key(user: 1).must_equal 'xxxccc'
  end


  after do
    Process.kill('INT', @rpc_server)
  end
end
