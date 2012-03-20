
begin
  require 'eventmachine/sync-defer'
rescue LoadError
end

begin
  require 'cool.io/sync-defer'
rescue LoadError
end

module SyncDefer
  module_function
  def defer *args, &block
    if Object.const_defined?(:EventMachine) && EventMachine.reactor_running?
      EventMachine::SyncDefer.defer(*args, &block)
    elsif Object.const_defined?(:Coolio) &&
          Coolio::Loop.default.has_active_watchers?
      Coolio::SyncDefer.defer(*args, &block)
    else
      $stderr.puts("SyncDefer: WARN: No reactor found. " \
                   "Only cool.io and eventmachine are supported.")
      $stderr.puts("           Called from: #{caller.last(5).inspect}")
      args << block if block_given?
      if args.size == 1
        args.first.call
      else
        args.map(&:call)
      end
    end
  end
end
