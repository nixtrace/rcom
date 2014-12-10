#!/usr/bin/env ruby
ENV['LOCAL'] = 'redis://localhost'

require 'rcom'

node = Rcom::Node.new('local').connect
messages = Rcom::Task.new(node: node, queue: 'messages')

messages.subscribe do |message|
  sleep 1
  p message
end
