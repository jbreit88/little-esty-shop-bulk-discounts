class BulkDiscountsController < ApplicationController
  before_action :holiday_facade, only: [:index]

  def index
    @merchant = Merchant.find(params[:merchant_id])
    @bulk_discounts = BulkDiscount.where(merchant_id: params[:merchant_id])
    @holiday_bulk_discounts = HolidayBulkDiscount.where(merchant_id: params[:merchant_id])
  end

  def show
    @bulk_discount = BulkDiscount.find(params[:id])
  end

  def new
    @merchant = Merchant.find(params[:merchant_id])
  end

  def create
    merchant = Merchant.find(params[:merchant_id])
    bulk_discount = merchant.bulk_discounts.create(bulk_discount_params)

    redirect_to merchant_bulk_discounts_path(merchant.id)
  end

  def edit
    @bulk_discount = BulkDiscount.find(params[:id])
    @merchant = Merchant.find(params[:merchant_id])
  end

  def update
    bulk_discount = BulkDiscount.find(params[:id])

    bulk_discount.update(bulk_discount_params)

    redirect_to merchant_bulk_discount_path(params[:merchant_id], params[:id])
  end

  def destroy
    bulk_discount = BulkDiscount.destroy(params[:id])

    redirect_to merchant_bulk_discounts_path(params[:merchant_id])
  end

  private

  def bulk_discount_params
    params.permit(:name, :threshold, :percent_discount)
  end

  def holiday_facade
    @holiday_facade = HolidayFacade.new
  end
end
