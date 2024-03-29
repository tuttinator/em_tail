require 'file-tail'
require 'redis'

@redis = Redis.new(:host => '127.0.0.1', :post => 6379)

filename = "sample.log"

File.open(filename) do |log|
  log.extend(File::Tail)      
  log.backward(10)    
  log.tail do |line|    
    @redis.publish 'ws', line        
  end          
end      
