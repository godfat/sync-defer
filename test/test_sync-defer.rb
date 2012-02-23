
require 'fiber'
require 'bacon'

begin
  require 'cool.io/sync-defer'
  describe Coolio::SyncDefer do
    should 'work' do
      result = []
      Fiber.new{
        result << Coolio::SyncDefer.defer{ sleep 0.1; result << 0; 1 }
        result << 2
      }.resume
      Coolio::Loop.default.run
      result.should.eql [0, 1, 2]
    end
  end
rescue LoadError => e
  puts "cool.io is not installed, skipping: #{e}"
end

begin
  require 'eventmachine/sync-defer'
  describe EventMachine::SyncDefer do
    should 'work' do
      result = []
      EM.run{
        Fiber.new{
          result << EM::SyncDefer.defer{ sleep 0.1; result << 0; 1 }
          result << 2
          EM.stop
        }.resume
      }
      result.should.eql [0, 1, 2]
    end
  end
rescue LoadError => e
  puts "eventmachine is not installed, skipping: #{e}"
end
