require 'rails_helper'

RSpec.describe Pair, type: :model do
  it 'update_ticker' do
    pair = Pair.create(name: 'tBTCUSD')
    data = pair.update_ticker
    if pair.ticker.nil?
      pair.create_ticker high: data[8], low: data[9]
    else
      pair.ticker.update_attributes high: data[8], low: data[9]
    end
    expect(pair.ticker).to_not be_nil
  end
end
