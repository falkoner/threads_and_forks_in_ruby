require 'minitest/autorun'
require "./worker_pool"

def fib(n)
  n < 2 ? n : fib(n-1) + fib(n-2)
end

describe WorkerPool do
  it 'allocates jobs to the workers and runs them in parallel' do
    expected_results = {
      0=>0, 1=>1, 2=>1, 3=>2, 4=>3,
      5=>5, 6=>8, 7=>13, 8=>21, 9=>34,
      10=>55, 11=>89, 12=>144, 13=>233, 14=>377,
      15=>610, 16=>987, 17=>1597, 18=>2584, 19=>4181,
      20=>6765, 21=>10946, 22=>17711, 23=>28657, 24=>46368,
      25=>75025, 26=>121393, 27=>196418, 28=>317811, 29=>514229
    }
    results = {}
    # pool = WorkerPool.new(10)
    pool = WorkerPool.new(5, LeastBusyFirstScheduler)

    Thread.new do
      30.times do |n|
        pool << -> { results[n] = fib(n) }
      end
      pool << :done
    end
    pool.wait

    assert_equal expected_results, results
  end
end
