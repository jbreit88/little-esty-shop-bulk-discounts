require 'rails_helper'

RSpec.describe 'Merchant Bulk Discounts Index Page', type: :feature do

  let!(:merchant_1) {Merchant.create!(name: 'Merchant 1', status: 0)}
  let!(:merchant_2) {Merchant.create!(name: 'Merchant 2', status: 0)}

  let!(:fifteen_off_ten) {merchant_1.bulk_discounts.create!(name: "Fifteen Off Ten", threshold: 10, percent_discount: 15)}
  let!(:twenty_off_fifteen) {merchant_1.bulk_discounts.create!(name: "Twenty Off Fifteen", threshold: 15, percent_discount: 20)}
  let!(:five_off_ten) {merchant_2.bulk_discounts.create!(name: "Five Off Ten", threshold: 10, percent_discount: 5)}

  context 'As a merchant when I visit my dashboard' do
    scenario 'I see a link to view my discounts' do
      visit merchant_dashboard_index_path(merchant_1.id)

      expect(page).to have_link("Discounts", href: merchant_bulk_discounts_path(merchant_1.id))
    end

    scenario 'I click the link and am taken to my bulk discounts index page' do
      visit merchant_dashboard_index_path(merchant_1.id)

      click_link('Discounts')

      expect(current_path).to eq(merchant_bulk_discounts_path(merchant_1.id))
    end

    scenario 'I see all my bulk discounts and their attributes' do
      visit merchant_bulk_discounts_path(merchant_1.id)

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

      expect(page).to have_no_content(five_off_ten.name)
    end

    scenario 'I see each bulk discount is a link to its own show page' do
      visit merchant_bulk_discounts_path(merchant_1.id)

      within "#bulk-discount-#{fifteen_off_ten.id}" do
        expect(page).to have_link(fifteen_off_ten.name, href: merchant_bulk_discount_path(merchant_1.id, fifteen_off_ten.id))
      end

      within "#bulk-discount-#{twenty_off_fifteen.id}" do
        expect(page).to have_link(twenty_off_fifteen.name, href: merchant_bulk_discount_path(merchant_1.id, twenty_off_fifteen.id))
      end
    end
  end

  context 'As a merchant when I visit my discounts index' do
    before(:each) do
      visit merchant_bulk_discounts_path(merchant_1.id)
    end

    scenario 'I see a link to create a new discount' do
      expect(page).to have_link('Create New Discount', href: new_merchant_bulk_discount_path(merchant_1.id))
    end

    scenario 'I click this link and am taken to a create page' do
      click_link 'Create New Discount'

      expect(current_path).to eq(new_merchant_bulk_discount_path(merchant_1.id))
    end

    context 'I see a delete link' do
      scenario 'Next to each bulk discount is a link to delete it' do
        within "#bulk-discount-#{fifteen_off_ten.id}" do
          expect(page).to have_link('Delete Discount', href: merchant_bulk_discount_path(merchant_1.id, fifteen_off_ten.id))
        end

        within "#bulk-discount-#{twenty_off_fifteen.id}" do
          expect(page).to have_link('Delete Discount', href: merchant_bulk_discount_path(merchant_1.id, twenty_off_fifteen.id))
        end
      end

      scenario 'When I click this link it redirectws to the index page and the discount is no longer listed' do
        expect(page).to have_content(fifteen_off_ten.name)
        expect(page).to have_content(twenty_off_fifteen.name)

        within "#bulk-discount-#{fifteen_off_ten.id}" do
          click_link 'Delete Discount'
        end

        expect(current_path).to eq(merchant_bulk_discounts_path(merchant_1.id))
        expect(page).to have_no_content(fifteen_off_ten.name)
        expect(page).to have_content(twenty_off_fifteen.name)

        within "#bulk-discount-#{twenty_off_fifteen.id}" do
          click_link 'Delete Discount'
        end

        expect(current_path).to eq(merchant_bulk_discounts_path(merchant_1.id))
        expect(page).to have_no_content(fifteen_off_ten.name)
        expect(page).to have_no_content(twenty_off_fifteen.name)
      end
    end
  end
end
