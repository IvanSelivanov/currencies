#Resque.enqueue(ApplicationJob, 'tBTCUSD')
#Resque.enqueue(ApplicationJob, 'tETHUSD')

Pair.all.each do |p|
  TickersWorker.perform_async p.name
end
