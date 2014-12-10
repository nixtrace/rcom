#!/usr/bin/env ruby
ENV['LOCAL'] = 'redis://localhost'

require 'rcom'

message = {
  id: 1,
  key: 'xxxccc'
}
node = Rcom::Node.new('local').connect
users = Rcom::Topic.new(node: node, key: 'users')

users.publish(message)
