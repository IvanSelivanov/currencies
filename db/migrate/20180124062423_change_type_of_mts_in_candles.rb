class ChangeTypeOfMtsInCandles < ActiveRecord::Migration[5.1]
  def change
    change_column :candles, :mts, :bigint
  end
end
