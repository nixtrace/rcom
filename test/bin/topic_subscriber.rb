#!/usr/bin/env ruby
ENV['local'] = 'redis://localhost'

require 'rcom'

node = Rcom::Node.new('local').connect
topic = Rcom::Topic.new(node: node, key: 'users')

topic.subscribe do |message|
  p message
end
