class BulkDiscount < ApplicationRecord
  belongs_to :merchant
  has_many :items, through: :merchant
  has_many :invoice_items, through: :items
  has_many :invoices, through: :merchant

  validates_presence_of :name
  validates_presence_of :percent_discount
  validates_presence_of :threshold


end
