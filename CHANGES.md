# CHANGES

## sync-defer 0.9.6 -- ?

* Fixed call stacks information in the warning.

## sync-defer 0.9.5 -- 2012-03-21

* Also fall back whenever it's not wrapped inside a fiber.

## sync-defer 0.9.4 -- 2012-03-21

* Fixed a bug that where there's an exception in multiple computations,
  the fiber should not be resumed twice or more times. This bug is caught
  by JRuby.

* `SyncDefer.defer` should also return only one value if there's only one
  computation.

## sync-defer 0.9.3 -- 2012-03-20

* Also work without a reactor in the generic interface: `SyncDefer.defer`,
  but print a warning about it.

## sync-defer 0.9.2 -- 2012-03-20

* Properly select the reactor.

* Made it exception aware. If there's an exception raised in the
  computation, sync-defer would resume back and raise that exception.

## sync-defer 0.9.1 -- 2012-02-25

* Added a generic interface which would pick the underneath reactor
  automatically. `SyncDefer.defer{ sleep(10) }`

* Added multi-defer:
  `SyncDefer.defer(lambda{ sleep(10) }, lambda{ sleep(5) })`
  which return the values inside an array according to the index.

## sync-defer 0.9.0 -- 2012-02-24

* Birthday!
