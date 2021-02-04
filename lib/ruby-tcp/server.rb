require "socket"
# require "colorize"
class Server
  def initialize( port, ip )
    @server = TCPServer.open(  port )
    @connections = Hash.new
    @rooms = Hash.new
    @clients = Hash.new
    @connections[:server] = @server
    @connections[:rooms] = @rooms
    @connections[:clients] = @clients
    run
  end

  # if user discos, server must be restarted. attempts to write to nonexisting tcpstream?? remove user from @connections[:clients] when they disco
  def run
    loop {
      Thread.start(@server.accept) do | client |
        nick_name = client.gets.chomp.to_sym
        @connections[:clients].each do |other_name, other_client|
          if nick_name == other_name || client == other_client
            client.puts "This username already exist"
            Thread.exit # lol
          end
        end
        puts "#{nick_name} #{client}"
        puts client.addr
        puts "#########################################################"
        @connections[:clients][nick_name] = client
        client.puts "Connection established, Thank you for joining! Happy chatting"
        listen_user_messages( nick_name, client )
      end
    }.join
  end

  def listen_user_messages( username, client )
    loop {
      msg = client.gets.chomp
      @connections[:clients].each do |other_name, other_client|
        unless other_name == username
          other_client.puts "#{username.to_s}: #{msg}"
        end
      end
    }
  end
end

# port only on docker image
# this file to be run on remote server
# Server.new(80)

Server.new(8080, "127.0.0.1")
