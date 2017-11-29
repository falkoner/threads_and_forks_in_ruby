class Worker
  attr_reader :name


  def initialize(name)
    @name = name
    @queue = Queue.new
    @pid = Thread.new { perform }
  end

  def <<(job)
    @queue << job
  end

  def jobs_count
    @queue.size
  end

  def join
    @pid.join
  end

  private

  def perform
    while (job = @queue.pop)
      break if job == :done
      job.call
      puts "#{name} got #{job}" # only for debugging
    end
  end
end
