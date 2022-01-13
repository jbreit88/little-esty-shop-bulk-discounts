class InvoicesController < ApplicationController
  # before_action :github_facade, only: [:index, :show, :update]

  def index
    @merchant = Merchant.find(params[:merchant_id])
    @invoices = @merchant.invoices
  end

  def show
    @invoice        = Invoice.find(params[:id])
    @merchant_items = @invoice.items_by_merchant(params[:merchant_id])
    @total_revenue  = @invoice.total_revenue_by_merchant(params[:merchant_id])
    @merchant = Merchant.find(params[:merchant_id])
  end

  def update
    @invoice = Invoice.find(params[:id])

    if params[:status]["packaged"]
      @invoice_item = InvoiceItem.find(params[:invoice_item_id])
      @invoice_item.update(status: 0)
    elsif params[:status]['pending']
      @invoice_item = InvoiceItem.find(params[:invoice_item_id])
      @invoice_item.update(status: 1)
    elsif params[:status]['shipped']
      @invoice_item = InvoiceItem.find(params[:invoice_item_id])
      @invoice_item.update(status: 2)
    end

    redirect_to merchant_invoice_path(params[:merchant_id], params[:id])
  end
end
