require 'rails_helper'

RSpec.describe 'Test explicit examples on bulk_discounts project page', type: :features do
  describe 'Example 1' do
    it 'provides no discounts when the item quantity on an invoice adds to item threshold, but not individual item meets that threshold' do
      merchant_a = Merchant.create!(name: 'Merchant A', status: 0)

      discount_a = merchant_a.bulk_discounts.create!(name: "Twenty Off Ten", threshold: 10, percent_discount: 20)

      item_a = merchant_a.items.create!(name: "Item A", description: "Item A", unit_price: 350)
      item_b = merchant_a.items.create!(name: "Item B", description: "Item B", unit_price: 200)

      customer_a = Customer.create!(first_name: "Customer", last_name: "A")

      invoice_a = customer_a.invoices.create!(status: 1, created_at: '2012-03-25 09:54:09')

      invoice_item_a = InvoiceItem.create!(quantity: 5, unit_price: item_a.unit_price, item_id: item_a.id, invoice_id: invoice_a.id, status: 0)
      invoice_item_b = InvoiceItem.create!(quantity: 5, unit_price: item_b.unit_price, item_id: item_b.id, invoice_id: invoice_a.id, status: 0)

      expect(invoice_a.total_invoice_discounts).to eq 0
    end
  end

  describe 'Example 2' do
    it 'provides discounts to items that meet the threshold quantity and not to ones that do not meet the threshold' do
      merchant_a = Merchant.create!(name: 'Merchant A', status: 0)

      discount_a = merchant_a.bulk_discounts.create!(name: "Twenty Off Ten", threshold: 10, percent_discount: 20)

      item_a = merchant_a.items.create!(name: "Item A", description: "Item A", unit_price: 350)
      item_b = merchant_a.items.create!(name: "Item B", description: "Item B", unit_price: 200)

      customer_a = Customer.create!(first_name: "Customer", last_name: "A")

      invoice_a = customer_a.invoices.create!(status: 1, created_at: '2012-03-25 09:54:09')

      invoice_item_a = InvoiceItem.create!(quantity: 10, unit_price: item_a.unit_price, item_id: item_a.id, invoice_id: invoice_a.id, status: 0)
      invoice_item_b = InvoiceItem.create!(quantity: 5, unit_price: item_b.unit_price, item_id: item_b.id, invoice_id: invoice_a.id, status: 0)

      expect(invoice_item_a.find_bulk_discount).to eq(discount_a)
      expect(invoice_item_b.find_bulk_discount).to eq(nil)

      expect(invoice_a.total_invoice_discounts).to eq((invoice_item_a.quantity * invoice_item_a.unit_price) * (discount_a.percent_discount / 100.00).to_f)
    end
  end

  describe 'Example 3' do
    it 'applies only the higher of two bulk discount percentages' do
      merchant_a = Merchant.create!(name: 'Merchant A', status: 0)

      discount_a = merchant_a.bulk_discounts.create!(name: "Twenty Off Ten", threshold: 10, percent_discount: 20)
      discount_b = merchant_a.bulk_discounts.create!(name: "Thirty Off Fifteen", threshold: 15, percent_discount: 30)

      item_a = merchant_a.items.create!(name: "Item A", description: "Item A", unit_price: 350)
      item_b = merchant_a.items.create!(name: "Item B", description: "Item B", unit_price: 200)

      customer_a = Customer.create!(first_name: "Customer", last_name: "A")

      invoice_a = customer_a.invoices.create!(status: 1, created_at: '2012-03-25 09:54:09')

      invoice_item_a = InvoiceItem.create!(quantity: 12, unit_price: item_a.unit_price, item_id: item_a.id, invoice_id: invoice_a.id, status: 0)
      invoice_item_b = InvoiceItem.create!(quantity: 15, unit_price: item_b.unit_price, item_id: item_b.id, invoice_id: invoice_a.id, status: 0)

      expect(invoice_item_a.find_bulk_discount).to eq(discount_a)
      expect(invoice_item_b.find_bulk_discount).to eq(discount_b)

      expect(invoice_a.total_invoice_discounts).to eq(((invoice_item_a.quantity * invoice_item_a.unit_price) * (discount_a.percent_discount / 100.00).to_f) + ((invoice_item_b.quantity * invoice_item_b.unit_price) * (discount_b.percent_discount / 100.00).to_f))
    end
  end

  describe 'Example 4' do
    it 'applies the highest percentage regardless of threshold quantity' do
      merchant_a = Merchant.create!(name: 'Merchant A', status: 0)

      discount_a = merchant_a.bulk_discounts.create!(name: "Twenty Off Ten", threshold: 10, percent_discount: 20)
      discount_b = merchant_a.bulk_discounts.create!(name: "Fifteen Off Fifteen", threshold: 15, percent_discount: 15)

      item_a = merchant_a.items.create!(name: "Item A", description: "Item A", unit_price: 350)
      item_b = merchant_a.items.create!(name: "Item B", description: "Item B", unit_price: 200)

      customer_a = Customer.create!(first_name: "Customer", last_name: "A")

      invoice_a = customer_a.invoices.create!(status: 1, created_at: '2012-03-25 09:54:09')

      invoice_item_a = InvoiceItem.create!(quantity: 12, unit_price: item_a.unit_price, item_id: item_a.id, invoice_id: invoice_a.id, status: 0)
      invoice_item_b = InvoiceItem.create!(quantity: 15, unit_price: item_b.unit_price, item_id: item_b.id, invoice_id: invoice_a.id, status: 0)

      expect(invoice_item_a.find_bulk_discount).to eq(discount_a)
      expect(invoice_item_b.find_bulk_discount).to eq(discount_a)

      expect(invoice_a.total_invoice_discounts).to eq(((invoice_item_a.quantity * invoice_item_a.unit_price) * (discount_a.percent_discount / 100.00).to_f) + ((invoice_item_b.quantity * invoice_item_b.unit_price) * (discount_a.percent_discount / 100.00).to_f))
    end
  end

  describe 'Example 5' do
    it 'Applies merchant bulk discounts only to merchant items when more than one merchant items are represented on an invoice' do
      merchant_a = Merchant.create!(name: 'Merchant A', status: 0)

      discount_a = merchant_a.bulk_discounts.create!(name: "Twenty Off Ten", threshold: 10, percent_discount: 20)
      discount_b = merchant_a.bulk_discounts.create!(name: "Thirty Off Fifteen", threshold: 15, percent_discount: 30)

      item_a_1 = merchant_a.items.create!(name: "Item A", description: "Item A", unit_price: 350)
      item_a_2 = merchant_a.items.create!(name: "Item B", description: "Item B", unit_price: 200)

      merchant_b = Merchant.create!(name: 'Merchant A', status: 0)

      item_b_1 = merchant_b.items.create!(name: "Item C", description: "Item C", unit_price: 500)

      customer_a = Customer.create!(first_name: "Customer", last_name: "A")

      invoice_a = customer_a.invoices.create!(status: 1, created_at: '2012-03-25 09:54:09')

      invoice_item_a = InvoiceItem.create!(quantity: 12, unit_price: item_a_1.unit_price, item_id: item_a_1.id, invoice_id: invoice_a.id, status: 0)
      invoice_item_b = InvoiceItem.create!(quantity: 15, unit_price: item_a_2.unit_price, item_id: item_a_2.id, invoice_id: invoice_a.id, status: 0)
      invoice_item_c = InvoiceItem.create!(quantity: 15, unit_price: item_b_1.unit_price, item_id: item_b_1.id, invoice_id: invoice_a.id, status: 0)

      expect(invoice_item_a.find_bulk_discount).to eq(discount_a)
      expect(invoice_item_b.find_bulk_discount).to eq(discount_b)
      expect(invoice_item_c.find_bulk_discount).to eq(nil)

      expect(invoice_a.total_invoice_discounts).to eq(((invoice_item_a.quantity * invoice_item_a.unit_price) * (discount_a.percent_discount / 100.00).to_f) + ((invoice_item_b.quantity * invoice_item_b.unit_price) * (discount_b.percent_discount / 100.00).to_f))
    end
  end
end
