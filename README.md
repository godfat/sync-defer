# sync-defer [![Build Status](http://travis-ci.org/godfat/sync-defer.png)](http://travis-ci.org/godfat/sync-defer)

by Lin Jen-Shin ([godfat](http://godfat.org))

## LINKS:

* [github](https://github.com/godfat/sync-defer)
* [rubygems](https://rubygems.org/gems/sync-defer)
* [rdoc](http://rdoc.info/github/godfat/sync-defer)

## DESCRIPTION:

Synchronous deferred operations with fibers (coroutines)

## REQUIREMENTS:

* Either cool.io or eventmachine
* Ruby 1.9+ (or if fibers could be used in Ruby 1.8)

## INSTALLATION:

    gem install sync-defer

## SYNOPSIS:

Remember to wrap a fiber around the client, and inside the client:

* Generic interface which would select underneath reactor automatically:

  ``` ruby
      # Single computation:
      puts(SyncDefer.defer{
                             sleep(10) # any CPU-bound operations
                             100})     # 100
      puts "DONE"

      # Multiple computations:
      puts(SyncDefer.defer(lambda{
                             sleep(10) # any CPU-bound operations
                             100
                           },
                           lambda{
                             sleep(5)  # any CPU-bound operations
                             50}))     # [100, 50] # it would match the index
      puts "DONE"
  ```

  Full examples with reactor turned on:

* with cool.io:

  ``` ruby
      # only for adding at least one watcher in the loop
      watcher = Coolio::AsyncWatcher.new.attach(Coolio::Loop.default)
      watcher.on_signal{detach}
      watcher.signal

      Fiber.new{
        # or Coolio::SyncDefer
        SyncDefer.defer{ sleep(10) }
        puts "DONE"
      }.resume
      Coolio::Loop.default.run
  ```

* with eventmachine:

  ``` ruby
      EM.run{
        Fiber.new{
          # or EM::SyncDefer
          SyncDefer.defer{ sleep(10) }
          puts "DONE"
          EM.stop
        }.resume
      }
  ```

* No problems with exceptions, use them as normal:

  ``` ruby
      EM.run{
        Fiber.new{
          begin
            SyncDefer.defer{ raise "BOOM" }
          rescue => e
            p e
          end
          EM.stop
        }.resume
      }
  ```

## CONTRIBUTORS:

* Lin Jen-Shin (@godfat)

## LICENSE:

Apache License 2.0

Copyright (c) 2012, Lin Jen-Shin (godfat)

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

<http://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
