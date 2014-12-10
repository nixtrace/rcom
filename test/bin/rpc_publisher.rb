#!/usr/bin/env ruby
ENV['LOCAL'] = 'redis://localhost'

require 'rcom'

message = {
  method: 'user.key',
  args: 1
}
node = Rcom::Node.new('local').connect
auth = Rcom::Rpc.new(node: node, service: 'auth')
p auth.request(message)
