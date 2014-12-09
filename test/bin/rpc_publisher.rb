#!/usr/bin/env ruby
ENV['LOCAL'] = 'redis://localhost'

require 'rcom'
require 'json'

message = {
  method: 'user.key',
  args: 1
}
node = Rcom::Node.new('local').connect
service = Rcom::Rpc.new(node: node, service: 'auth')
p service.request(message)
