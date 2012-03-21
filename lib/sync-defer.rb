
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
    if root_fiber?
      fallback("Not called inside a fiber.", *args, &block)

    elsif Object.const_defined?(:EventMachine) &&
          EventMachine.reactor_running?
      EventMachine::SyncDefer.defer(*args, &block)

    elsif Object.const_defined?(:Coolio) &&
          Coolio::Loop.default.has_active_watchers?
      Coolio::SyncDefer.defer(*args, &block)

    else
      fallback("No reactor found.", *args, block)
    end
  end

  def root_fiber?
    RootFiber == Fiber.current
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
