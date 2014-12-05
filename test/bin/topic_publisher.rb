#!/usr/bin/env ruby
ENV['local'] = 'redis://localhost'

require 'rcom'
require 'json'

message = {
  id: 1,
  key: 'xxxccc'
}
node = Rcom::Node.new('local').connect
topic = Rcom::Topic.new(node: node, key: 'users')

topic.publish(message)
