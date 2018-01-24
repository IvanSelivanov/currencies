class CreateTickers < ActiveRecord::Migration[5.1]
  def change
    create_table :tickers do |t|
      t.references :pair
      t.float :high
      t.float :low

      t.timestamps
    end
  end
end
