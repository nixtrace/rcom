# Rcom

[Redis](http://redis.io) inter-service messaging: request-response, publish-subscribe and task queues. A thin, minimal layer on top of [Redis-rb](https://github.com/redis/redis-rb).

## Installation.

- [Install](http://redis.io/topics/quickstart) a local Redis server and start it:
```sh
# OSX example
$ brew install redis
$ redis-server
```

- Add rcom to your Gemfile:
```ruby
gem 'rcom'
```

## Usage.

Rcom supports the request-response, publish-subscribe and task queues patterns for inter-service messaging. Publishers are non-blocking, subscribers/consumers are blocking and should be run as independent processes. Processes communicate using MessagePack internally.

### Node.

A node represents a Redis connection to a server address specified with an ENV variable.

```ruby
# Specify this in your .env file.
ENV['local'] = 'redis://localhost'

node = Rcom::Node.new('local').connect
```

### Topics.

One service might need to update many different services about an event, following the publish-subscribe pattern. You can publish and subscribe to topics on a node, specifying a key.

- Publisher.

```ruby
message = {
  id: 1,
  key: 'xxxccc'
}

node = Rcom::Node.new('local').connect
topic = Rcom::Topic.new(node: node, key: 'users')

topic.publish(message)
```

- Subscriber.

```ruby
node = Rcom::Node.new('local').connect
topic = Rcom::Topic.new(node: node, key: 'users')

topic.subscribe do |message|
  p message
end
```

## Tasks.

A service might need to push expensive tasks into a queue and forget about them. Tasks will be processed by consumers listening to the queue.

- Publisher.

```ruby
message = {
  id: 1,
  key: 'xxxccc'
}

node = Rcom::Node.new('local').connect
messages = Rcom::Task.new(node: node, queue: 'messages')

messages.publish(message)
```

- Consumer.

```ruby
node = Rcom::Node.new('local').connect
messages = Rcom::Task.new(node: node, queue: 'messages')

messages.subscribe do |message|
  sleep 1
  p message
end
```

## RPC, requests and responses.

In some cases services need real time informations from other services that can't be asynchronously processed. A service can create a request on a route. The other service listening on the same route will reply to the request.

- Publisher.

```ruby
message = {
  route: 'user.key',
  args: 1
}

node = Rcom::Node.new('local').connect
auth = Rcom::Rpc.new(node: node, service: 'auth')

auth.request(message)
```

- Consumer.

```ruby
node = Rcom::Node.new('local').connect
auth = Rcom::Rpc.new(node: node, service: 'auth')

auth.subscribe do |request|
  request.on('user.key') do |params|
    request.reply = 'xxxccc'
  end

  request.on('user.password') do |params|
    request.reply = 'not authorized'
  end
end
```

## Test.

- Be sure you have a local Redis server running.

- run tests with:
```ruby
bundle exec rake test:spec
```

## Contributing.

1. Fork it ( https://github.com/badshark/rcom/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License.

[MIT](LICENSE.txt)
