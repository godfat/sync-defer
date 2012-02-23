# sync-defer [![Build Status](http://travis-ci.org/godfat/sync-defer.png)](http://travis-ci.org/godfat/sync-defer)

by Lin Jen-Shin ([godfat](http://godfat.org))

## LINKS:

* [github](https://github.com/godfat/sync-defer)
* [rubygems](https://rubygems.org/gems/sync-defer)
* [rdoc](http://rdoc.info/github/godfat/sync-defer)

## DESCRIPTION:

Synchronous deferred operations with fibers (coroutines)

## REQUIREMENTS:

Either cool.io or eventmachine

## INSTALLATION:

    gem install sync-defer

## SYNOPSIS:

Remember to wrap a fiber around the client, and inside the client:

### with cool.io:

    Coolio::SyncDefer{
      sleep(10) # any CPU-bound operations
    }
    puts "DONE"

### with eventmachine:

    EventMachine::SyncDefer{
      sleep(10) # any CPU-bound operations
    }
    puts "DONE"

Full examples:

### with cool.io:

    Fiber.new{
      Coolio::SyncDefer.defer{ sleep(10) } # any CPU-bound operations
      puts "DONE"
    }.resume
    Coolio::Loop.default.run

### with eventmachine:

    EM.run{
      Fiber.new{
        EM::SyncDefer.defer{ sleep(10) } # any CPU-bound operations
        puts "DONE"
        EM.stop
      }.resume
    }

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
