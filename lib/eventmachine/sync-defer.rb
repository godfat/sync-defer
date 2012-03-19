
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
    result = Fiber.yield
    if result.kind_of?(Exception)
      raise result
    else
      result
    end
  end

  def defer_one fiber, func
    EventMachine.defer(lambda_with_rescue(func),
                       lambda{ |result| fiber.resume(result)})
  end

  def defer_multi fiber, funcs
    results = {}
    funcs.each.with_index do |func, index|
      EventMachine.defer(
        lambda_with_rescue(func),
        lambda{ |result|
          if result.kind_of?(Exception)
            fiber.resume(result)
          else
            results[index] = result
            fiber.resume(results.sort.map(&:last)) if
              results.size == funcs.size
          end
        })
    end
  end

  def lambda_with_rescue func
    lambda{
      begin
        func.call
      rescue Exception => e
        e
      end
    }
  end
end
