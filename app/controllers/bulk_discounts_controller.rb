class BulkDiscountsController < ApplicationController

  def index
    @merchant = Merchant.find(params[:merchant_id])
    @bulk_discounts = BulkDiscount.where(merchant_id: params[:merchant_id])
  end

  def show
  end

  def new
  end

  def create
    merchant = Merchant.find(params[:merchant_id])
    bulk_discount = merchant.bulk_discounts.create(bulk_discount_params)

    redirect_to merchant_bulk_discounts_path(merchant.id)
  end

  private

  def bulk_discount_params
    params.require(:bulk_discount).permit(:name, :threshold, :percent_discount)
  end
end
