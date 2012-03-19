
require 'fiber'
require 'bacon'
require 'rr'

include RR::Adapters::RRMethods

require 'sync-defer'

class TestException < Exception
end

begin
  require 'cool.io/sync-defer'
  [Coolio::SyncDefer, SyncDefer].each do |defer|
    describe defer do
      before do
        stub(Object).const_defined?(:EventMachine){ false }
        stub(Object).const_defined?(:Coolio)      { true  }
      end

      after do
        RR.verify
      end

      should 'defer_one' do
        result = []
        Fiber.new{
          result << defer.defer{ sleep 0.1; result << 0; 1 }
          result << defer.defer(lambda{ 2 })
          result << 3
        }.resume
        Coolio::Loop.default.run
        result.should.eql [0, 1, 2, 3]
      end

      should 'defer_multi' do
        result = []
          Fiber.new{
            result.concat(defer.defer(lambda{ sleep 0.1; 1 },
                                      lambda{ result << 0; 2 }))
            result << 3
          }.resume
        Coolio::Loop.default.run
        result.should.eql [0, 1, 2, 3]
      end
    end
  end
rescue LoadError => e
  puts "cool.io is not installed, skipping: #{e}"
end

begin
  require 'eventmachine/sync-defer'
  [EventMachine::SyncDefer, SyncDefer].each do |defer|
    describe defer do
      before do
        stub(Object).const_defined?(:EventMachine){ true }
      end

      after do
        RR.verify
      end

      should 'defer_one' do
        result = []
        EM.run{
          Fiber.new{
            result << defer.defer{ sleep(0.1); result << 0; 1 }
            result << defer.defer(lambda{ 2 })
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
            result.concat(defer.defer(lambda{ sleep(0.1); 1 },
                                      lambda{ result << 0; 2 }))
            result << 3
            EM.stop
          }.resume
        }
        result.inspect.should == [0, 1, 2, 3].inspect
      end

      should 'raise the exception' do
        EM.run{
          Fiber.new{
            lambda{
              defer.defer{ raise TestException }
            }.should.raise(TestException)
            EM.stop
          }.resume
        }
      end
    end
  end
rescue LoadError => e
  puts "eventmachine is not installed, skipping: #{e}"
end
