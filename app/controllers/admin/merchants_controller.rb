class Admin::MerchantsController < ApplicationController
  # before_action :github_facade, only: [:index, :show, :new, :create, :edit, :update]
  
  def index
    @merchants = Merchant.all
  end

  def show
    @merchant = Merchant.find(params[:id])
  end

  def new
  end

  def create
    @merchant = Merchant.create(merch_params)
    redirect_to admin_merchants_path
  end

  def edit
    @merchant = Merchant.find(params[:id])
  end

  def update
    merchant = Merchant.find(params[:id])

    if params[:disable]
      merchant.update(status: params[:disable].to_i)
      redirect_to admin_merchants_path
    elsif params[:enable]
      merchant.update(status: params[:enable].to_i)
      redirect_to admin_merchants_path
    else
      merchant.update(merch_params)
      redirect_to admin_merchant_path(merchant.id)
      flash[:notice] = "Successfully Updated Merchant Information"
    end
  end

  private

  def merch_params
    params.require(:merchant).permit(:name, :status)
  end

end
