
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
    result, exception = Fiber.yield
    if exception
      raise exception
    else
      result
    end
  end

  def defer_one fiber, func
    exception = nil
    EventMachine.defer(lambda{
                         begin
                           func.call
                         rescue Exception => e
                           exception = e
                         end
                       },
                       lambda{ |result| fiber.resume(result, exception)})
  end

  def defer_multi fiber, funcs
    results, exception = {}, nil
    funcs.each.with_index do |func, index|
      EventMachine.defer(
        lambda{
          begin
            func.call
          rescue Exception => e
            exception = e
          end
        },
        lambda{ |result|
          if exception
            fiber.resume(nil, exception) if fiber.alive?
          else
            results[index] = result
            fiber.resume(results.sort.map(&:last), nil) if
              results.size == funcs.size && fiber.alive?
          end
        })
    end
  end
end
