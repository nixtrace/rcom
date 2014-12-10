#!/usr/bin/env ruby
ENV['LOCAL'] = 'redis://localhost'

require 'rcom'

node = Rcom::Node.new('local').connect
service = Rcom::Rpc.new(node: node, service: 'auth')

service.subscribe do |request|
  request.on('user.key') do |params|
    request.reply = 'xxxccc'
  end
end
