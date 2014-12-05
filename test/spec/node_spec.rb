require_relative './_init'

describe 'Node' do
  before do
    ENV['LOCAL'] = 'redis://127.0.0.1'
    @local = Rcom::Node.new('local')
  end

  it 'represents a Node' do
    @local.must_be_instance_of Rcom::Node
  end

  it 'cannot represent a node not present in ENV' do
    lambda do
      Rcom::Node.new('mail')
    end.must_raise ArgumentError
  end

  it 'has a Redis connection to the node' do
    connection = @local.connection
    connection.must_be_instance_of Redis
  end
end