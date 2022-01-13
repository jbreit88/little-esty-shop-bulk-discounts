class DashboardController < ApplicationController
  before_action :github_facade, only: [:index]

  def index
    @merchant = Merchant.find(params[:merchant_id])
  end
end
