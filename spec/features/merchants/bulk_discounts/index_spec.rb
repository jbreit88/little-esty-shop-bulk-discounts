require 'rails_helper'

RSpec.describe 'Merchant Bulk Discounts Index Page', type: :feature do

  let!(:merchant_1) {Merchant.create!(name: 'Merchant 1', status: 0)}

  let!(:fifteen_off_ten) {merchant_1.bulk_discounts.create!(name: "Fifteen Off Ten", threshold: 10, percent_discount: 15)}
  let!(:twenty_off_fifteen) {merchant_1.bulk_discounts.create!(name: "Twenty Off Fifteen", threshold: 15, percent_discount: 20)}

  context 'As a merchant when I visit my dashboard' do
    scenario 'I see a link to view my discounts' do
      visit merchant_dashboard_path(merchant_1.id)

      expect(page).to have_link("Discounts", href: merchant_discounts_path(merchant_1.id))
    end

    scenario 'I click the link and am taken to my bulk discounts index page' do
      visit merchant_dashboard_path(merchant_1.id)

      click_link('Discounts')

      expect(current_path).to eq(merchant_discounts_path(merchant_1.id))
    end

    scenario 'I see all my bulk discounts and their attributes' do
      visit merchant_discounts_path(merchant_1.id)

      within "#bulk-discount-#{fifteen_off_ten.id}" do
        expect(page).to have_content(fifteen_off_ten.name)
        expect(page).to have_content(fifteen_off_ten.percent_discount)
        expect(page).to have_content(fifteen_off_ten.threshold)
      end

      within "#bulk-discount-#{twenty_off_fifteen.id}" do
        expect(page).to have_content(twenty_off_fifteen.name)
        expect(page).to have_content(twenty_off_fifteen.percent_discount)
        expect(page).to have_content(twenty_off_fifteen.threshold)
      end
    end

    scenario 'I see each bulk discount is a link to its own show page' do
      within "#bulk-discount-#{fifteen_off_ten.id}" do
        expect(page).to have_link(fifteen_off_ten.name, href: merchant_descount_path(merchant_1.id, fifteen_off_ten.id))
      end

      within "#bulk-discount-#{twenty_off_fifteen.id}" do
        expect(page).to have_link(twenty_off_fifteen.name, href: merchant_descount_path(merchant_1.id, twenty_off_fifteen.id))
      end
    end
  end
end

# Merchant Bulk Discounts Index
#
# As a merchant
# When I visit my merchant dashboard
# Then I see a link to view all my discounts
# When I click this link
# Then I am taken to my bulk discounts index page
# Where I see all of my bulk discounts including their
# percentage discount and quantity thresholds
# And each bulk discount listed includes a link to its show page
