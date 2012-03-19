# CHANGES

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
