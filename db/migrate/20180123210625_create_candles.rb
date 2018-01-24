class CreateCandles < ActiveRecord::Migration[5.1]
  def change
    create_table :candles do |t|
      t.references :pair, foreign_key: true
      t.integer :mts
      t.float :open
      t.float :close
      t.float :high
      t.float :low

      t.timestamps
    end
  end
end
