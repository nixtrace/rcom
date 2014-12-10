#!/usr/bin/env ruby
ENV['local'] = 'redis://localhost'

require 'rcom'

node = Rcom::Node.new('local').connect
users = Rcom::Topic.new(node: node, key: 'users')

users.subscribe do |message|
  p message
end
