
require 'fiber'

begin
  require 'eventmachine/sync-defer'
rescue LoadError
end

begin
  require 'cool.io/sync-defer'
rescue LoadError
end

module SyncDefer
  # assume we would always require 'rest-core' in root fiber
  RootFiber = Fiber.current

  module_function
  def defer *args, &block
    if fiber_wrapped?
      if Object.const_defined?(:EventMachine) &&
         EventMachine.reactor_running?
        EventMachine::SyncDefer.defer(*args, &block)

      elsif Object.const_defined?(:Coolio) &&
            Coolio::Loop.default.has_active_watchers?
        Coolio::SyncDefer.defer(*args, &block)

      else
        fallback("No reactor found.", *args, block)
      end

    else
      fallback("Not called inside a fiber.", *args, &block)
    end
  end

  def fiber_wrapped?
    # because under a thread, Fiber.current won't return the root fiber
    RootFiber != Fiber.current && Thread.main == Thread.current
  end

  def fallback message, *args, &block
    $stderr.puts("SyncDefer: WARN: #{message}")
    $stderr.puts("           Falling back to run the computation directly.")
    $stderr.puts("           Called from: #{caller.first(5).inspect}")
    args << block if block_given?
    if args.size == 1
      args.first.call
    else
      args.map(&:call)
    end
  end
end
