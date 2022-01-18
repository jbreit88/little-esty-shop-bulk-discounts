require 'rails_helper'

RSpec.describe 'Admin Invoice Show page' do
  let!(:customer_1) {Customer.create!(first_name: "Billy", last_name: "Joel")}

  let!(:merchant_1) {Merchant.create!(name: 'Ron Swanson', status: 0)}

  let!(:item_1) {merchant_1.items.create!(name: "Necklace", description: "A thing around your neck", unit_price: 1000, status: 0)}
  let!(:item_2) {merchant_1.items.create!(name: "Bracelet", description: "A thing around your wrist", unit_price: 900, status: 0)}
  let!(:item_3) {merchant_1.items.create!(name: "Earrings", description: "These go through your ears", unit_price: 1500, status: 1)}

  let!(:invoice_1) {customer_1.invoices.create!(status: 1, created_at: '2012-03-25 09:54:09')}

  let!(:invoice_item_1)  {InvoiceItem.create!(item_id: item_1.id, invoice_id: invoice_1.id, unit_price: item_1.unit_price, quantity: 2, status: 0)}
  let!(:invoice_item_2)  {InvoiceItem.create!(item_id: item_2.id, invoice_id: invoice_1.id, unit_price: item_2.unit_price, quantity: 26, status: 0)}
  let!(:invoice_item_3)  {InvoiceItem.create!(item_id: item_3.id, invoice_id: invoice_1.id, unit_price: item_3.unit_price, quantity: 2, status: 0)}

  let!(:bulk_discount_1) {merchant_1.bulk_discounts.create!(name: "Ten off Ten", threshold: 10, percent_discount: 10)}

  before(:each) do
    visit admin_invoice_path(invoice_1.id)
  end

  context 'When an admin visits the admin invoice show page' do
    scenario 'admin sees invoice attributes' do
      expect(page).to have_content(invoice_1.id)
      expect(page).to have_content(invoice_1.creation_date_formatted)
      expect(page).to have_content(customer_1.first_name)
      expect(page).to have_content(customer_1.last_name)
    end

    scenario 'admin sees all items on invoice' do
      expect(page).to have_content(item_1.name)
      expect(page).to have_content(item_1.unit_price.to_f/100)
      expect(page).to have_content(invoice_item_1.quantity)
      expect(page).to have_content(invoice_item_3.status)
    end

    context 'there is an invoice item status field' do
      scenario 'visitor sees invoice status is a select field next to invoice with current status selected' do
        expect(page).to have_field('status', with: 'completed')
        expect(page).to have_button('Update Invoice Status')
      end

      scenario 'visitor can select new status and update by clicking submit button' do
        expect(page).to have_field('status', with: 'completed')
        expect(page).to have_button('Update Invoice Status')

        select 'Cancelled', from: 'status'
        click_button('Update Invoice Status')

        expect(current_path).to eq(admin_invoice_path(invoice_1.id))
        expect(page).to have_field('status', with: 'cancelled')

        select 'In Progress', from: 'status'
        click_button('Update Invoice Status')

        expect(current_path).to eq(admin_invoice_path(invoice_1.id))
        expect(page).to have_field('status', with: 'in progress')

        select 'Completed', from: 'status'
        click_button('Update Invoice Status')

        expect(current_path).to eq(admin_invoice_path(invoice_1.id))
        expect(page).to have_field('status', with: 'completed')
      end
    end

    context 'admin sees section for total revenue' do
      scenario 'admin sees total revenue generated from this invoice' do
        expect(page).to have_content(invoice_1.invoice_items.revenue.to_f/100)
      end
    end

    context 'admin sees section for total discounted revenue' do
      scenario 'displays total discounted revenue for this invoice including the bulk discounts calculation' do
        merchant_3 = Merchant.create!(name: 'Ron Swanson', status: 0)
        merchant_4 = Merchant.create!(name: 'Mike Cheney', status: 0)

        item_5 = merchant_3.items.create!(name: "Necklace", description: "A thing around your neck", unit_price: 2000, status: 0)
        item_6 = merchant_3.items.create!(name: "Bracelet", description: "A thing around your wrist", unit_price: 900, status: 0)
        item_7 = merchant_4.items.create!(name: "Earrings", description: "These go through your ears", unit_price: 1500, status: 1)

        customer_2 = Customer.create!(first_name: "Billy", last_name: "Joel")

        invoice_4 = customer_2.invoices.create!(status: 1, created_at: '2012-03-25 09:54:09')

        invoice_item_6 = InvoiceItem.create!(item_id: item_5.id, invoice_id: invoice_4.id, unit_price: item_5.unit_price, quantity: 2, status: 0)
        invoice_item_7 = InvoiceItem.create!(item_id: item_6.id, invoice_id: invoice_4.id, unit_price: item_6.unit_price, quantity: 26, status: 0)
        invoice_item_8 = InvoiceItem.create!(item_id: item_7.id, invoice_id: invoice_4.id, unit_price: item_7.unit_price, quantity: 6, status: 0)

        bulk_discount_1 = merchant_3.bulk_discounts.create!(name: "Ten off Ten", threshold: 10, percent_discount: 10)
        bulk_discount_2 = merchant_4.bulk_discounts.create!(name: "Five off Five", threshold: 5, percent_discount: 5)

        visit admin_invoice_path(invoice_4.id)

        expect(page).to have_content((invoice_4.invoice_items.revenue.to_f/100) - (invoice_4.total_invoice_discounts.to_f/100))
      end
    end
  end
end
