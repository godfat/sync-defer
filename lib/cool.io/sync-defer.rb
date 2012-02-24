
require 'fiber'
require 'cool.io'

module Coolio::SyncDefer
  module_function
  def defer *args, &block
    loop  = args.find  { |a| a.kind_of?(Coolio::Loop) }||Coolio::Loop.default
    funcs = args.reject{ |a| a.kind_of?(Coolio::Loop) }
    funcs << block if block_given?
    if funcs.size == 1
      DeferOne.new(funcs.first, loop).result
    else
      DeferMulti.new(funcs, loop).result
    end
  end

  class Defer < Coolio::AsyncWatcher
    attr_reader :result
    def initialize loop=Coolio::Loop.default
      super()
      self.fiber = Fiber.current
      attach(loop)
      yield
      Fiber.yield
    end

    protected
    attr_accessor :fiber
    attr_writer   :result
    def on_signal
      detach
      fiber.resume(result)
    end
  end

  class DeferOne < Defer
    def initialize func=lambda{}, loop=Coolio::Loop.default
      super(loop){ defer(func) }
    end

    protected
    def defer func
      Thread.new{
        self.result = func.call
        signal
      }
    end
  end

  class DeferMulti < Defer
    def initialize funcs=[lambda{}], loop=Coolio::Loop.default
      super(loop){ defer(funcs) }
    end

    protected
    attr_accessor :values, :target
    def defer funcs
      self.values = {}
      self.target = funcs.size
      funcs.each.with_index do |func, index|
        Thread.new{
          values[index] = func.call
          signal
        }
      end
    end

    def on_signal
      return if values.size != target
      self.result = values.sort.map(&:last)
      super
    end
  end
end
