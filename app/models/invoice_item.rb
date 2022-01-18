class InvoiceItem < ApplicationRecord
  enum status: ["packaged", "pending", "shipped"]

  validates_presence_of :quantity,
                        :unit_price,
                        :item_id,
                        :invoice_id


  belongs_to :invoice
  belongs_to :item

  has_many :bulk_discounts, through: :item

  def self.revenue
    sum('quantity * unit_price')
  end

  def find_bulk_discount
    # ActiveRecord
    bulk_discounts.where("bulk_discounts.threshold <= ?", quantity)
    .order(percent_discount: :desc)
    .first
  end
end
