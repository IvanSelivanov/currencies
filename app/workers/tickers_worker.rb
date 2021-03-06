require_relative '../../lib/ws'
class TickersWorker
  include Sidekiq::Worker
#  sidekiq_options queue: 'critical'

  def perform(pair)
    puts 'performing sidekiq'
    client = Bitfinex::Client.new

    client.listen_ticker(pair) do |tick|
      data = tick[1]

      p = Pair.find_by_name pair
      if p.ticker.nil?
        p.create_ticker high: data[8], low: data[9]
      else
        p.ticker.update_attributes high: data[8], low: data[9], last: data[6]
      end

      puts "Last Price: #{data[6]}\t High: #{data[8]}\t Low: #{data[9]}"
      ActionCable.server.broadcast 'ticker_channel',  pair: pair, high: data[8], low: data[9], last: data[6]
    end

    puts "Bitfinex Ticker Price for #{pair}:"
    client.listen!
  end
end
