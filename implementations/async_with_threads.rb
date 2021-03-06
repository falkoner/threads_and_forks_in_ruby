require "./lib/mailer"
require "benchmark"

threads = []

puts Benchmark.measure{
  100.times do |i|
    threads << Thread.new do
      Mailer.deliver do
        from    "eki_#{i}@eqbalq.com"
        to      "jill_#{i}@example.com"
        subject "Threading and Forking (#{i})"
        body    "Some content"
      end
    end
  end
  threads.map(&:join)
}
