class AddPercentDiscountToBulkDiscounts < ActiveRecord::Migration[5.2]
  def change
    add_column :bulk_discounts, :percent_discount, :integer
  end
end
