module App
  module BitfinexApi
    def self.included(c)
      c.extend ClassMethods
    end

    def update_ticker
      data = self.class.api_request "https://api.bitfinex.com/v2/ticker/" + name

      unless data[0]=='error'
        if ticker.nil?
          create_ticker high: data[8], low: data[9]
        else
          ticker.update_attributes high: data[8], low: data[9]
        end
      end
    end

    def update_candles
#      start = DateTime.now.prev_day.at_beginning_of_day.to_time.to_i*1000
      finish = DateTime.now.prev_day.at_end_of_day.to_time.to_i*1000
#      endpoint = "https://api.bitfinex.com/v2/candles/trade:1D:#{name}/hist?start=#{start}&end=#{finish}"
      endpoint = "https://api.bitfinex.com/v2/candles/trade:1D:#{name}/hist?limit=10&end=#{finish}"
      data = self.class.api_request(endpoint)
      data.each do |c|
        candles.find_or_create_by mts: c[0], open: c[1], close: c[2], high: c[3], low: c[4]
      end unless data[0]=='error'
    end

    module ClassMethods
      def update_symbols
        data = api_request "https://api.bitfinex.com/v1/symbols"
        data.each do |n|
          find_or_create_by name: 't'+n.upcase
        end unless data[0]=='error'
      end

      def api_request(endpoint)
        url = URI(endpoint)
        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true
        request = Net::HTTP::Get.new(url)
        response = http.request(request)
        JSON.parse response.read_body
      end
    end
  end
end