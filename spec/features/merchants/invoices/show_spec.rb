require 'rails_helper'

RSpec.describe 'Merchant Invoice Show Page', type: :feature do

  let!(:merchant_1) {Merchant.create!(name: 'Ron Swanson')}
  let!(:merchant_2) {Merchant.create!(name: 'Deb Millhouse')}

  let!(:item_1) {merchant_1.items.create!(name: "Necklace", description: "A thing around your neck", unit_price: 150, status: 1)}
  let!(:item_2) {merchant_1.items.create!(name: "Bracelet", description: "A thing around your wrist", unit_price: 300, status: 0)}
  let!(:item_3) {merchant_2.items.create!(name: "Earrings", description: "A thing around your ears", unit_price: 220, status: 0)}
  let!(:item_4) {merchant_2.items.create!(name: "Button", description: "A thing for your pants", unit_price: 150)}
  let!(:item_5) {merchant_1.items.create!(name: "Pokemon Card", description: "A thing for your pants", unit_price: 150, status: 0)}

  let!(:customer_1) {Customer.create!(first_name: "Billy", last_name: "Joel")}

  let!(:invoice_1)  {customer_1.invoices.create!(status: 1, created_at: '2012-03-25 09:54:09')}

  let!(:invoice_item_1) {InvoiceItem.create!(quantity: 3, unit_price: item_1.unit_price, item_id: item_1.id, invoice_id: invoice_1.id, status: 0)}
  let!(:invoice_item_2) {InvoiceItem.create!(quantity: 5, unit_price: item_2.unit_price, item_id: item_2.id, invoice_id: invoice_1.id, status: 1)}
  let!(:invoice_item_3) {InvoiceItem.create!(quantity: 5, unit_price: item_5.unit_price, item_id: item_5.id, invoice_id: invoice_1.id, status: 2)}

  before (:each) do
    visit merchant_invoice_path(merchant_1.id, invoice_1.id)
  end

  describe 'Merchant sees invoice attributes on page' do
    it 'displays invoice id' do
      expect(page).to have_content(invoice_1.id)
    end

    it 'displays invoice status' do
      expect(page).to have_content(invoice_1.status)
    end

    it 'displays invoice created_at date in format DAY, MM DD,YYYY' do
      expect(page).to have_content(invoice_1.creation_date_formatted)
    end

    it 'displays customer first and last name' do
      expect(page).to have_content(customer_1.first_name)
      expect(page).to have_content(customer_1.last_name)
    end
  end

  describe 'merchant item information displays' do
    scenario 'merchant sees information for only their items associated with invoice including item name, quantity, price, status' do
      expect(page).to have_no_content(item_3.name)
      expect(page).to have_no_content(item_4.name)

      within "#item#{item_1.id}" do
        expect(page).to have_content(item_1.name)
        expect(page).to have_content(invoice_item_1.quantity)
        expect(page).to have_content(invoice_item_1.status)
        expect(page).to have_content(invoice_item_1.unit_price.to_f/100)
      end

      within "#item#{item_2.id}" do
        expect(page).to have_content(item_2.name)
        expect(page).to have_content(invoice_item_2.quantity)
        expect(page).to have_content(invoice_item_2.status)
        expect(page).to have_content(invoice_item_2.unit_price.to_f/100)
      end
    end

    scenario 'merchant sees total revenue from the sale of their items on an invoice' do
      total_revenue = (invoice_item_1.unit_price * invoice_item_1.quantity) + (invoice_item_2.unit_price * invoice_item_2.quantity) + (invoice_item_3.unit_price * invoice_item_3.quantity)

      expect(page).to have_content(total_revenue.to_f/100)
    end
  end

  describe 'item status update field' do
    scenario 'merchant sees item status select field  and submit button next to each item' do
      within "#item#{item_1.id}" do
        expect(page).to have_field('Status', with: 'packaged')
        expect(page).to have_button("Update Item Status")
      end

      within "#item#{item_2.id}" do
        expect(page).to have_field('Status', with: 'pending')
        expect(page).to have_button("Update Item Status")
      end

      within "#item#{item_5.id}" do
        expect(page).to have_field('Status', with: 'shipped')
        expect(page).to have_button("Update Item Status")
      end
    end

    scenario 'the item select field is populated by item status and changes when updated' do
      within "#item#{item_1.id}" do
        expect(page).to have_field('Status', with: 'packaged')
        expect(page).to have_button("Update Item Status")

        select "Pending", from: "Status"
        click_button("Update Item Status")

        expect(current_path).to eq(merchant_invoice_path(merchant_1.id, invoice_1.id))
        expect(page).to have_field('Status', with: 'pending')
        expect(page).to have_no_field('Status', with: 'packaged')

        select "Shipped", from: "Status"
        click_button("Update Item Status")

        expect(current_path).to eq(merchant_invoice_path(merchant_1.id, invoice_1.id))
        expect(page).to have_field('Status', with: 'shipped')
        expect(page).to have_no_field('Status', with: 'pending')

        select "Packaged", from: "Status"
        click_button("Update Item Status")

        expect(current_path).to eq(merchant_invoice_path(merchant_1.id, invoice_1.id))
        expect(page).to have_field('Status', with: 'packaged')
        expect(page).to have_no_field('Status', with: 'shipped')
      end
    end
  end
end

RSpec.describe 'Merchant Invoice Show Page', type: :feature do
  let!(:merchant_1) {Merchant.create!(name: 'Ron Swanson')}
  let!(:merchant_2) {Merchant.create!(name: 'Deb Millhouse')}

  let!(:item_1) {merchant_1.items.create!(name: "Necklace", description: "A thing around your neck", unit_price: 150, status: 1)}
  let!(:item_2) {merchant_1.items.create!(name: "Bracelet", description: "A thing around your wrist", unit_price: 300, status: 0)}
  let!(:item_3) {merchant_2.items.create!(name: "Earrings", description: "A thing around your ears", unit_price: 220, status: 0)}


  let!(:customer_1) {Customer.create!(first_name: "Billy", last_name: "Joel")}

  let!(:invoice_1)  {customer_1.invoices.create!(status: 1, created_at: '2012-03-25 09:54:09')}

  let!(:invoice_item_1) {InvoiceItem.create!(quantity: 10, unit_price: item_1.unit_price, item_id: item_1.id, invoice_id: invoice_1.id, status: 0)}
  let!(:invoice_item_2) {InvoiceItem.create!(quantity: 5, unit_price: item_2.unit_price, item_id: item_2.id, invoice_id: invoice_1.id, status: 1)}
  let!(:invoice_item_3) {InvoiceItem.create!(quantity: 10, unit_price: item_3.unit_price, item_id: item_3.id, invoice_id: invoice_1.id, status: 2)}

  let!(:bulk_discount_1) {merchant_1.bulk_discounts.create!(name: "Ten Off Ten", threshold: 10, percent_discount: 10)}

  before (:each) do
    visit merchant_invoice_path(merchant_1.id, invoice_1.id)
  end

  context 'As a merchant when I visit an invoice show page' do
    scenario 'I see the total revenue for my merchant without discounts' do
      total_merchant_revenue = (invoice_item_1.unit_price * invoice_item_1.quantity) + (invoice_item_2.unit_price * invoice_item_2.quantity)

      expect(page).to have_content(total_merchant_revenue.to_f/100)
    end

    scenario 'I see the total discount for my merchant including bulk discounts' do
      total_merchant_discounted_revenue = invoice_1.total_revenue_by_merchant(merchant_1.id) - invoice_1.total_discounts_by_merchant(merchant_1.id)

      expect(page).to have_content(total_merchant_discounted_revenue.to_f/100)
    end

    scenario 'next to each invoice item I see a link to the bulk discount show page that was applied if any' do
      save_and_open_page
      within "#item#{item_1.id}" do
        expect(page).to have_link(bulk_discount_1.name, href: merchant_bulk_discount_path(merchant_1.id, bulk_discount_1.id))
        expect(page).to have_no_content('None')
      end

      within "#item#{item_2.id}" do
        expect(page).to_not have_link(bulk_discount_1.name, href: merchant_bulk_discount_path(merchant_1.id, bulk_discount_1.id))
        expect(page).to have_content("None")
      end
    end
  end
end
