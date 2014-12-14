#!/usr/bin/env ruby
ENV['LOCAL'] = 'redis://localhost'

require 'rcom'

class Server
  def get_key(params)
    return nil unless params[:user] == 1
    return 'xxxccc'
  end
end

node = Rcom::Node.new('local').connect
auth = Rcom::Response.new(
  node: node,
  channel: 'auth',
  server: Server.new
)

auth.serve
