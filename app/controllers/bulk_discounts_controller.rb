class BulkDiscountsController < ApplicationController

  def index
    @bulk_discounts = BulkDiscount.where(merchant_id: params[:merchant_id])
  end

end
