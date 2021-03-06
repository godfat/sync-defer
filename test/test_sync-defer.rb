
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
        @watcher = Coolio::AsyncWatcher.new.attach(Coolio::Loop.default)
        @watcher.on_signal{detach}
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
          @watcher.signal
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
            @watcher.signal
          }.resume
        Coolio::Loop.default.run
        result.should.eql [0, 1, 2, 3]
      end

      should 'raise the exception' do
        Fiber.new{
          lambda{
            defer.defer{ raise TestException }
          }.should.raise(TestException)
          @watcher.signal
        }.resume
        Coolio::Loop.default.run
      end

      should 'one of them raise' do
        Fiber.new{
          lambda{
            defer.defer(lambda{ raise TestException }, lambda{})
          }.should.raise(TestException)

          lambda{
            defer.defer(lambda{}, lambda{ raise TestException })
          }.should.raise(TestException)
          @watcher.signal
        }.resume
        Coolio::Loop.default.run
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
        result.inspect.should.eql [0, 1, 2, 3].inspect
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
        result.inspect.should.eql [0, 1, 2, 3].inspect
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

      should 'one of them raise' do
        EM.run{
          Fiber.new{
            lambda{
              defer.defer(lambda{ raise TestException }, lambda{})
            }.should.raise(TestException)

            lambda{
              defer.defer(lambda{}, lambda{ raise TestException })
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

describe SyncDefer do
  describe 'fallback' do
    before do mock($stderr).puts(is_a(String)).times(3) end
    after  do RR.verify                                 end

    should 'also work without a reactor, but print a warning' do
      SyncDefer.defer{ 123 }.should.eql 123
    end

    should 'multiple computations' do
      SyncDefer.defer(lambda{1}, lambda{2}){ 3 }.
        inspect.should.eql [1, 2, 3].inspect
    end

    should 'also fallback if there is no fibers in EM' do
      EM.run{ SyncDefer.defer{ 1 }.should.eql 1; EM.stop }
    end if Object.const_defined?(:EventMachine)

    should 'also fallback if there is no fibers in Coolio' do
      watcher = Coolio::AsyncWatcher.new.attach(Coolio::Loop.default)
      watcher.on_signal{detach}
      SyncDefer.defer{ 1 }.should.eql 1
      watcher.signal
      Coolio::Loop.default.run
    end if Object.const_defined?(:Coolio)
  end

  describe 'no yield' do
    should 'not yield if there is nothing to do in EM' do
      EM.run{Fiber.new{ SyncDefer.defer.should.eql nil; EM.stop }.resume}
    end if Object.const_defined?(:EventMachine)

    should 'not yield if there is nothing to do in Coolio' do
      watcher = Coolio::AsyncWatcher.new.attach(Coolio::Loop.default)
      watcher.on_signal{detach}
      Fiber.new{SyncDefer.defer.should.eql nil}.resume
      watcher.signal
      Coolio::Loop.default.run
    end if Object.const_defined?(:Coolio)
  end
end
