require 'rails_helper'

RSpec.describe HolidayBulkDiscount, type: :model do
  describe 'relationships' do
    it { should belong_to(:merchant) }
    it { should have_many(:items).through(:merchant) }
    it { should have_many(:invoice_items).through(:items) }
    it { should have_many(:invoices).through(:merchant) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:percent_discount) }
    it { should validate_presence_of(:threshold) }

    it { should validate_numericality_of(:percent_discount).is_greater_than(0).is_less_than_or_equal_to(100) }
    it { should validate_numericality_of(:threshold) }
  end

  describe 'Class Methods' do
    describe '::existing_holiday_discounts' do
      it 'returns a unique array of holiday names for holiday_bulk_discounts' do
        merchant_1 = Merchant.create!(name: 'Ron Swanson')
        merchant_2 = Merchant.create!(name: 'Bella Donna')

        holiday_bulk_discount_1 = merchant_1.holiday_bulk_discounts.create!(name: "Presidents Day", threshold: 10, percent_discount: 15, holiday: 'Presidents Day')
        holiday_bulk_discount_2 = merchant_1.holiday_bulk_discounts.create!(name: "Memorial Day", threshold: 20, percent_discount: 10, holiday: 'Memorial Day')
        holiday_bulk_discount_3 = merchant_2.holiday_bulk_discounts.create!(name: "Juneteenth", threshold: 20, percent_discount: 10, holiday: 'Juneteenth')
        holiday_bulk_discount_4 = merchant_2.holiday_bulk_discounts.create!(name: "Presidents Day", threshold: 20, percent_discount: 10, holiday: 'Presidents Day')

        expect(HolidayBulkDiscount.existing_holiday_discounts).to eq(['Presidents Day', 'Memorial Day', 'Juneteenth'])
      end
    end
  end
end
