require_relative './_init'

describe 'Task' do
  before do
    ENV['LOCAL'] = 'redis://localhost'
    @node = Rcom::Node.new('local').connect
    @task = Rcom::Task.new(node: @node, channel: 'messages')
  end

  it 'represents a Task' do
    @task.must_be_instance_of Rcom::Task
  end

  it 'can publishe a task and subscribe to receive it' do
    original_message = {
      id: 1,
      key: 'xxxccc'
    }
    reader, writer = IO.pipe

    @subscriber = fork {
      @task.subscribe do |message|
        writer.write message
      end
    }
    Process.detach @subscriber
    sleep 1

    @task.publish(original_message)
    sleep 1

    Process.kill('INT', @subscriber)

    writer.close
    eval(reader.read).must_equal original_message
    reader.close
  end
end
