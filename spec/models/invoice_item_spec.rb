require 'rails_helper'

RSpec.describe InvoiceItem do
  describe 'validation' do
    it { should define_enum_for(:status).with_values([:packaged, :pending, :shipped]) }
    it { should validate_presence_of(:quantity) }
    it { should validate_presence_of(:unit_price) }
    it { should validate_presence_of(:item_id) }
    it { should validate_presence_of(:invoice_id) }
  end

  describe 'relations' do
    it { should belong_to :invoice }
    it { should belong_to :item }
    it { should have_many(:bulk_discounts).through(:item) }
  end

  let!(:merchant_1) {Merchant.create!(name: 'Ron Swanson')}
  let!(:merchant_2) {Merchant.create!(name: 'Bella Donna')}

  let!(:item_1) {merchant_1.items.create!(name: "Necklace", description: "A thing around your neck", unit_price: 350)}
  let!(:item_2) {merchant_1.items.create!(name: "Bracelet", description: "A thing around your wrist", unit_price: 200)}
  let!(:item_3) {merchant_2.items.create!(name: "Necklace", description: "A thing around your neck", unit_price: 1000)}
  let!(:item_4) {merchant_2.items.create!(name: "Bracelet", description: "A thing around your wrist", unit_price: 150)}

  let!(:customer_1) {Customer.create!(first_name: "Billy", last_name: "Joel")}

  let!(:invoice_1) {customer_1.invoices.create!(status: 1, created_at: '2012-03-25 09:54:09')}

  let!(:invoice_item_1) {InvoiceItem.create!(quantity: 3, unit_price: item_1.unit_price, item_id: item_1.id, invoice_id: invoice_1.id, status: 0)}
  let!(:invoice_item_2) {InvoiceItem.create!(quantity: 5, unit_price: item_2.unit_price, item_id: item_2.id, invoice_id: invoice_1.id, status: 0)}
  let!(:invoice_item_3) {InvoiceItem.create!(quantity: 1, unit_price: item_3.unit_price, item_id: item_3.id, invoice_id: invoice_1.id, status: 0)}

  describe 'class methods' do
    describe '::revenue' do
      it 'returns the revenue of an invoice' do
        expect(InvoiceItem.revenue).to eq(3050)
      end
    end
  end

  describe 'instance methods' do
    describe '#find_bulk_discount' do
      it 'returns the bulk discount with the highest percentage if there is one for an invoice item' do
        invoice_2 = customer_1.invoices.create!(status: 1, created_at: '2012-03-25 09:54:09')

        invoice_item_4 = InvoiceItem.create!(quantity: 11, unit_price: item_1.unit_price, item_id: item_1.id, invoice_id: invoice_2.id, status: 0)
        invoice_item_5 = InvoiceItem.create!(quantity: 1, unit_price: item_1.unit_price, item_id: item_1.id, invoice_id: invoice_2.id, status: 0)

        bulk_discount_1 = merchant_1.bulk_discounts.create!(name: 'Ten off Ten', threshold: 10, percent_discount: 10)


        expect(invoice_item_4.find_bulk_discount).to eq(bulk_discount_1)

        expect(invoice_item_5.find_bulk_discount).to eq(nil)
      end

      it 'returns the highest percentage discount when more than one applies' do
        invoice_2 = customer_1.invoices.create!(status: 1, created_at: '2012-03-25 09:54:09')

        invoice_item_4 = InvoiceItem.create!(quantity: 11, unit_price: item_1.unit_price, item_id: item_1.id, invoice_id: invoice_2.id, status: 0)
        invoice_item_5 = InvoiceItem.create!(quantity: 6, unit_price: item_1.unit_price, item_id: item_1.id, invoice_id: invoice_2.id, status: 0)

        bulk_discount_1 = merchant_1.bulk_discounts.create!(name: 'Ten off Ten', threshold: 10, percent_discount: 10)
        bulk_discount_2 = merchant_1.bulk_discounts.create!(name: 'Five off Five', threshold: 5, percent_discount: 5)

        expect(invoice_item_4.find_bulk_discount).to eq(bulk_discount_1)
        expect(invoice_item_5.find_bulk_discount).to eq(bulk_discount_2)
      end
    end
  end
end
