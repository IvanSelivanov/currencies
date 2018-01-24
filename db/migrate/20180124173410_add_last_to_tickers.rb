class AddLastToTickers < ActiveRecord::Migration[5.1]
  def change
    add_column :tickers, :last, :float
  end
end
