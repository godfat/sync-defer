
require 'fiber'
require 'eventmachine'

module EventMachine::SyncDefer
  module_function
  def defer &block
    fiber = Fiber.current
    EventMachine.defer(lambda{ yield },
                       lambda{ |result| fiber.resume(result)})
    Fiber.yield
  end
end
