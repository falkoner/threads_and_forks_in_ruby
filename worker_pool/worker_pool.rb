# see https://hspazio.github.io/2017/worker-pool/

require "./worker"

class WorkerPool

  # unbound queue
  # def initialize(num_workers)
  #   @queue = Queue.new
  #   @workers = Array.new(num_workers) { |n|
  #     Worker.new("worker_#{n}", @queue)
  #   }
  # end

  # # bound queue
  # def initialize(num_workers)
  #   @queue = SizedQueue.new(num_workers)
  #   @workers = Array.new(num_workers) { |n|
  #     Worker.new("worker_#{n}", @queue)
  #   }
  # end
  #
  # def <<(job)
  #   if job == :done
  #     @workers.size.times { @queue << :done }
  #   else
  #     @queue << job
  #   end
  # end

  # use with schedulers
  # for ex.: pool = WorkerPool.new(5, LeastBusyFirstScheduler)
  def initialize(num_workers, scheduler_factory)
    @workers = Array.new(num_workers) { |n| Worker.new("worker_#{n}") }
    @scheduler = scheduler_factory.new(@workers)
  end

  def <<(job)
    if job == :done
      @workers.map { |w| w << :done }
    else
      @scheduler.schedule(job)
    end
  end

  def wait
    @workers.map(&:join)
  end
end


class LeastBusyFirstScheduler
  def initialize(workers)
    @workers = workers
  end

  def schedule(job)
    worker = @workers.sort_by(&:jobs_count).first
    worker << job
  end
end

class RoundRobinScheduler
  def initialize(workers)
    @current_worker = workers.cycle
  end

  def schedule(job)
    @current_worker.next << job
  end
end

class TopicScheduler
  TOPICS = [:service_1, :service_2, :service_3]

  def initialize(workers)
    @workers = {}
    workers_per_topic = workers / TOPICS.size
    workers.each_slice(workers_per_topic).each_with_index do |slice, index|
      topic = TOPICS[index]
      @workers[topic] = slice
    end
  end

  def schedule(job)
    worker = @workers[job.topic].sort_by(&:jobs_count).first
    worker << job
  end
end
