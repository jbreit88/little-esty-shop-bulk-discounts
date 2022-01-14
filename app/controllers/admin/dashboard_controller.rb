class Admin::DashboardController < ApplicationController
  # before_action :github_facade, only: [:index]

  def index
    @top_5 = Customer.top_5
    @incomplete_invoices = Invoice.incomplete_invoices
  end
end
