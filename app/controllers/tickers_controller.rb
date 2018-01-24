class TickersController < ApplicationController
  before_action :set_pair
  def update
    @ticker = @pair.update_ticker
    redirect_to @pair
  end
  protected
    def set_pair
      @pair = Pair.find params[:pair_id]
    end
end
