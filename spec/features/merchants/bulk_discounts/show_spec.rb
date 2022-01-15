require 'rails_helper'

RSpec.describe 'Bulk Discount Show Page', type: :feature do
  let!(:merchant_1) {Merchant.create!(name: 'Merchant 1', status: 0)}

  let!(:fifteen_off_ten) {merchant_1.bulk_discounts.create!(name: "Fifteen Off Ten", threshold: 10, percent_discount: 15)}
  let!(:twenty_off_fifteen) {merchant_1.bulk_discounts.create!(name: "Twenty Off Fifteen", threshold: 15, percent_discount: 20)}

  context 'As a merchant, when I visit a bulk discount show page' do
    scenario 'I see discount quantity threshold and percentage discount' do
      visit merchant_bulk_discount_path(merchant_1.id, fifteen_off_ten.id)

      expect(page).to have_content(fifteen_off_ten.name)
      expect(page).to have_content(fifteen_off_ten.percent_discount)
      expect(page).to have_content(fifteen_off_ten.threshold)

      expect(page).to have_no_content(twenty_off_fifteen.name)
    end
  end
end
