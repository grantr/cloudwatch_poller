# Cloudwatch Polling

# Cloudwatch basics
  - Designed as a metrics aggregator
  - No push, only pull
  - only option for direct ELB monitoring
  - Asking for too much data returns an error

# Problem overview
  - lots of timers
  - need to split requests that are too big
  - Ensure that output is faster than input
# Solution
  - Multithreaded
  - Divide and Conquer
  - Load sensing by measuring poll time
  - Rely on CW to scale throughput with concurrency
# Actors
  - Overview
  - Actors in Erlang
  - Let it Crash
# Celluloid
  - tarcieri
  - Components
  - Examples
# Why use Celluloid?
  - It's Ruby
  - Compare to eventmachine
# Why not use Celluloid?
  - It's not Erlang
  - Immature
# Stateful or Stateless
  - Problem is inherently stateful
  - Stateful harder to deploy and manage (but heroku makes it easier)
  - Can we avoid state and not lose data?
  - Why I chose Stateless
    - Easier to write and scale
    - No coordination/locks
    - Scaling easier to control and tune
  - Stateful alternatives
    - Requires locks
    - Redis atomic getset or queues (but queues require coordinators)
    - Competition/herds
    - Easier process scaling
# Demo
# Issues encountered
  - Initial design, changes made to accomodate cloudwatch api
  - Celluloid immaturity (kill -9, deadlocks)
# Improvements to be made
  - Tests
  - Backfills
  - Metric removal
  - Formatting
  - Throttling
  - Shrinking
  - Sharding
  - Config
  - Crash recovery / linking
  - Jruby
# Unanswered questions
  - Will it handle production load
  - Can it catch up if it gets behind
  - When does the growth start to run out of control
# Q/A
