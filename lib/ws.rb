require 'eventmachine'
require 'faye/websocket'
require 'json'

module Bitfinex
  module WebsocketConnection

    def listen!
      subscribe_to_channels
      listen
      ws_client.run!
    end

    def ws_send(msg)
      ws_client.send msg
    end

    def ws_close_all
      ws_client.stop!
      @ws_open = false
      ws_reset_channels
    end


    # Call the specified block passing tickers, it uses websocket
    #
    # @param pair [string]
    # @param block [Block] The code to be executed when a new ticker is sent by the server
    # @example:
    #   client.listen_ticker do |tick|
    #     puts tick.inspect
    #   end
    def listen_ticker(pair="BTCUSD", &block)
      raise BlockMissingError unless block_given?
      register_channel pair: pair, channel: "ticker", &block
    end


    private

      def ws_reset_channels
        @chan_ids = []
        @ws_registration_messages = []
        @callbacks = {}
      end

      def ws_client
        @ws_client ||= WSClient.new
      end

      def chan_ids
        @chan_ids ||= []
      end

      def ws_open
        @ws_open ||= false
      end

      def ws_registration_messages
        @ws_registration_messages ||= []
      end

      def callbacks
        @callbacks ||= []
      end

      def add_callback(&block)
        id = 0
        @mutex.synchronize do
          callbacks[@c_counter] = { block: block, chan_id: nil }
          id = @c_counter
          @c_counter += 1
        end
        id
      end

      def ws_safe_send(msg)
        if ws_open
          ws_client.send msg
        else
          ws_registration_messages.push msg
        end
      end

      def register_channel(msg, &block)
        sub_id = add_callback(&block)
        msg.merge!(subId: sub_id.to_s)
        if ws_open
          ws_client.send msg.merge(event: 'subscribe')
        else
          ws_registration_messages.push msg.merge(event: 'subscribe')
        end
      end

      def listen
        ws_client.on(:message) do |rmsg|
          msg = JSON.parse(rmsg)
          if msg.kind_of?(Hash) && msg["event"] == "subscribed"
            save_channel_id(msg["subId"],msg["chanId"])
          elsif msg.kind_of?(Array)
            exec_callback_for(msg)
          end
        end
      end

      def save_channel_id(sub_id,chan_id)
        callbacks[sub_id.to_i][:chan_id] = chan_id
        chan_ids[chan_id] = sub_id.to_i
      end

      def exec_callback_for(msg)
        return if msg[1] == 'hb' #ignore heartbeat
        id = msg[0]
        callbacks[chan_ids[id.to_i]][:block].call(msg)
      end

      def subscribe_to_channels
        ws_client.on(:open) do
          @ws_open = true
          ws_registration_messages.each do |msg|
            ws_client.send(msg)
          end
        end
      end

      class WSClient
        def initialize(options = {})
          # set some defaults
          @url = 'wss://api.bitfinex.com/ws/2'

          @reconnect = true
          @reconnect_after = 30
          @stop = false
        end

        def on(msg, &blk)
          ivar = "@#{msg}_cb"
          instance_variable_set(ivar.to_sym, blk)
        end

        def run!
          if EventMachine.reactor_running?
            connect!
          else
            EM.run { connect! }
          end
        end

        def stop!
          @stop = true
          @ws.close
        end

        def connect!
          @stop = false
          @ws = Faye::WebSocket::Client.new(@url)
          @ws.onopen = method(:ws_opened)
          @ws.onmessage = method(:ws_receive)
          @ws.onclose = method(:ws_closed)
          @ws.onerror = method(:ws_error)
        end

        def send(msg)
          raise ConnectionClosed if stopped?
          connect! unless alive?
          msg = msg.is_a?(Hash) ? msg.to_json : msg
          @ws.send(msg)
        end

        def alive?
          @ws && @ws.ready_state == Faye::WebSocket::API::OPEN
        end

        def stopped?
          @stop
        end

        private

          def ws_opened(event)
            @open_cb.call(event) if @open_cb
          end

          def ws_receive(event)
            @message_cb.call(event.data) if @message_cb
          end

          def ws_closed(event)
            if @stop
              EM.stop
            elsif @reconnect
              EM.add_timer(@reconnect_after){ connect! }
            end
          end

          def ws_error(event)
#            raise WebsocketError, event.message
          end
      end
  end
end


module Bitfinex
  class Client
    include Bitfinex::WebsocketConnection

    def initialize
      @mutex = Mutex.new
      @c_counter = 1
    end
  end
end

