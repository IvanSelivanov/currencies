require_relative '../../lib/ws'
class ApplicationJob
  @queue = :tickers
  def self.perform(pair)
    puts 'performing'
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
    end

    puts "Bitfinex Ticker Price for #{pair}:"
    client.listen!
  end
end
