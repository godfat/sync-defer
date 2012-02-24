
require 'fiber'
require 'eventmachine'

module EventMachine::SyncDefer
  module_function
  def defer *funcs, &block
    fiber = Fiber.current
    funcs << block if block_given?
    if funcs.size == 1
      defer_one(fiber, funcs.first)
    else
      defer_multi(fiber, funcs)
    end
    Fiber.yield
  end

  def defer_one fiber, func
    EventMachine.defer(lambda{ func.call },
                       lambda{ |result| fiber.resume(result)})
  end

  def defer_multi fiber, funcs
    results = {}
    funcs.each.with_index do |func, index|
      EventMachine.defer(
        lambda{ func.call },
        lambda{ |result|
          results[index] = result
          fiber.resume(results.sort.map(&:last)) if results.size == funcs.size
        })
    end
  end
end
