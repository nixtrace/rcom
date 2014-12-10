require_relative './_init'

describe 'Task' do
  before do
    ENV['LOCAL'] = 'redis://localhost'
    @node = Rcom::Node.new('local').connect
    @task = Rcom::Task.new(node: @node, queue: 'messages')
  end

  it 'represents a Task' do
    @task.must_be_instance_of Rcom::Task
  end

  it 'can pubish a task' do
    message = {
      id: 1,
      key: 'xxxccc'
    }
    @task.publish(message).must_equal true
  end

  it 'works in a pub/consumer scenario' do
    message = {
      id: 1,
      key: 'xxxccc'
    }
    completed_job = ''
    publisher = 'bundle exec ruby test/bin/task_publisher.rb'
    consumer = 'bundle exec ruby test/bin/task_consumer.rb'

    # Start the consumer, wait for it to be up,
    # start the publisher and wait for the message
    # on the consumer side. Process, then kill
    # the long-running consumer.
    Open3.popen3(consumer) do |stdin, stdout, stderr, wait_thr|
      sleep 1
      spawn(publisher)
      completed_job = stdout.gets
      Process.kill('INT', wait_thr.pid)
    end

    eval(completed_job.chomp).must_equal message
  end
end
