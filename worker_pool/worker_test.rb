require 'minitest/autorun'
require "./worker"

describe Worker do
  it 'has a name' do
    worker = Worker.new('worker_1', Queue.new)

    assert_equal 'worker_1', worker.name
  end

  it 'listens to jobs in the queue and performs them' do
    queue = Queue.new
    worker = Worker.new('worker_1', queue)
    results = []

    Thread.new do
      queue << -> { results.push('received job 1') }
      queue << -> { results.push('received job 2') }
      queue << :done
    end

    assert_equal [], results
    worker.join
    assert_equal ['received job 1', 'received job 2'], results
  end
end
