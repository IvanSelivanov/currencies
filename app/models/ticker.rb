class Ticker < ApplicationRecord
  belongs_to :pair
  def old?
    updated_at.to_date < Date.today
  end
end
