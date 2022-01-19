class HolidayBulkDiscountsController < ApplicationController

  def new
    @holiday_name = params[:holiday_name]
  end

  def create
    merchant = Merchant.find(params[:merchant_id])
    holiday_discount = merchant.holiday_bulk_discounts.create(holiday_discount_params)

    redirect_to merchant_bulk_discounts_path
  end

  private

  def holiday_discount_params
    params.require(:holiday_bulk_discount).permit(:name, :threshold, :percent_discount, :holiday)
  end

end
