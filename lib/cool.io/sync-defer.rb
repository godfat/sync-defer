
require 'fiber'
require 'cool.io'

class Coolio::SyncDefer < Coolio::AsyncWatcher
  def self.defer loop=Coolio::Loop.default, &block
    new(loop, &block).result
  end

  attr_reader :result

  def initialize loop=Coolio::Loop.default
    super()
    @fiber = Fiber.current
    attach(loop)
    Thread.new{
      @result = yield
      signal
    }
    Fiber.yield
  end

  def on_signal
    detach
    @fiber.resume(result)
  end
end
