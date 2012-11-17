require 'redis'
require 'em-websocket'

SOCKETS = []
@redis = Redis.new(:host => '127.0.0.1', :post => 6379)

# TODO: Create CSS classes for each of these spans
def escape_to_html(data)
  { 1 => :bold,
    2 => :nothing,
    4 => :underline,
    5 => :blink,
    7 => :nothing,
    30 => :black,
    31 => :red,
    32 => :green,
    33 => :yellow,
    34 => :blue,
    35 => :magenta,
    36 => :cyan,
    37 => :white,
    40 => :black_background,
    41 => :green_background,
    43 => :yellow_background,
    44 => :blue_background,
    45 => :magenta_background,
    46 => :cyan_background,
    47 => :white_background,
  }.each do |key, value|
    if value != :nothing
      data.gsub!(/\e\[#{key}m/,"<span class=\"#{value}\">")
    else
      data.gsub!(/\e\[#{key}m/,"<span>")
    end
  end
  data.gsub!(/\e\[0m/,'</span>')
  return data
end


# Creating a thread for the EM event loop
Thread.new do
  EventMachine.run do
    # Creates a websocket listener
    EventMachine::WebSocket.start(:host => '0.0.0.0', :port => 8081) do |ws|
      ws.onopen do
        # When someone connects I want to add that socket to the SOCKETS array that
        # I instantiated above
        puts "creating socket"
        SOCKETS << ws
      end

      ws.onclose do
        # Upon the close of the connection I remove it from my list of running sockets
        puts "closing socket"
        SOCKETS.delete ws
      end
    end
  end
end

# Creating a thread for the redis subscribe block
Thread.new do
  @redis.subscribe('ws') do |on|
    # When a message is published to 'ws'
    on.message do |chan, msg|
     puts "sending message: #{msg}"
     # Send out the message on each open socket
     SOCKETS.each {|s| s.send escape_to_html(msg)} 
    end
  end
end

sleep

