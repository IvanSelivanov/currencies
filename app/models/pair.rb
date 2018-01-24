require 'uri'
require 'net/http'
require_relative '../../lib/bitfinex_api'

class Pair < ApplicationRecord

  include App::BitfinexApi

  has_one :ticker, dependent: :destroy
  has_many :candles, dependent: :destroy

  def candles_old?
    Time.at(candles.order(:mts).last.mts/1000)<1.hour.before(DateTime.now.prev_day.at_end_of_day)
  end

  def chart_data
    data = []
    candle_collection = candles.order(:mts).last(30)
    candle_collection.each do |c|
      data << [
          Time.at(c.mts/1000).strftime("%d.%m.%Y"),
          c.low,
          c.open,
          c.close,
          c.high
      ]
    end
    data_table = GoogleVisualr::DataTable.new
    data_table.new_column('string', 'date')
    data_table.new_column('number', 'min')
    data_table.new_column('number', 'opening')
    data_table.new_column('number', 'closing')
    data_table.new_column('number', 'max')
    data_table.add_rows(data)
    data_table
  end
end
