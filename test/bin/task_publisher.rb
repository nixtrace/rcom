#!/usr/bin/env ruby
ENV['LOCAL'] = 'redis://localhost'

require 'rcom'
require 'json'

message = {
  id: 1,
  key: 'xxxccc'
}
node = Rcom::Node.new('local').connect
messages = Rcom::Task.new(node: node, queue: 'messages')
messages.publish(message)
