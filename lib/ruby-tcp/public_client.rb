require "json"
# require "colorize"
require "socket"
class Client
  def initialize
    @remote_ip = nil
    @remote_port = nil
    self.get_config
    @server = TCPSocket.new(@remote_ip.to_s, @remote_port.to_i)
    @request = nil
    @response = nil
    listen
    send
    @request.join
    @response.join
  end

  def listen
    @response = Thread.new do
      loop {
        msg = @server.gets.chomp
        puts "#{msg}"
      }
    end
  end

  def send
    puts "Enter the username:"
    @request = Thread.new do
      loop {
        msg = $stdin.gets.chomp
        @server.puts( msg )
      }
    end
  end

  def get_config
    file = File.read("./config.json")
    hash = JSON.parse(file)
    if hash["remote_host_ip"].nil? || hash["remote_host_port"].nil?
      puts "Please enter Server IP"
      ip = gets.chomp
      hash["remote_host_ip"] = ip
      puts "Please enter Server Port"
      port = gets.chomp
      hash["remote_host_port"] = port
    end
    @remote_ip = hash["remote_host_ip"]
    @remote_port = hash["remote_host_port"]
      
    File.open("config.json", "w+") do |f|
      f.write(JSON.dump(hash))
    end
  end
end

Client.new
