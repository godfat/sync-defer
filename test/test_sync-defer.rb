
require 'fiber'
require 'bacon'

begin
  require 'cool.io/sync-defer'
  describe Coolio::SyncDefer do
    should 'defer_one' do
      result = []
      Fiber.new{
        result << Coolio::SyncDefer.defer{ sleep 0.1; result << 0; 1 }
        result << Coolio::SyncDefer.defer(lambda{ 2 })
        result << 3
      }.resume
      Coolio::Loop.default.run
      result.should.eql [0, 1, 2, 3]
    end

    should 'defer_multi' do
      result = []
        Fiber.new{
          result.concat(Coolio::SyncDefer.defer(lambda{ sleep 0.1; 1 },
                                                lambda{ result << 0; 2 }))
          result << 3
        }.resume
      Coolio::Loop.default.run
      result.should.eql [0, 1, 2, 3]
    end
  end
rescue LoadError => e
  puts "cool.io is not installed, skipping: #{e}"
end

begin
  require 'eventmachine/sync-defer'
  describe EventMachine::SyncDefer do
    should 'defer_one' do
      result = []
      EM.run{
        Fiber.new{
          result << EM::SyncDefer.defer{ sleep(0.1); result << 0; 1 }
          result << EM::SyncDefer.defer(lambda{ 2 })
          result << 3
          EM.stop
        }.resume
      }
      result.inspect.should == [0, 1, 2, 3].inspect
    end

    should 'defer_multi' do
      result = []
      EM.run{
        Fiber.new{
          result.concat(EM::SyncDefer.defer(lambda{ sleep(0.1); 1 },
                                            lambda{ result << 0; 2 }))
          result << 3
          EM.stop
        }.resume
      }
      result.inspect.should == [0, 1, 2, 3].inspect
    end
  end
rescue LoadError => e
  puts "eventmachine is not installed, skipping: #{e}"
end
