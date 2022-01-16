require 'rails_helper'

RSpec.describe 'Bulk Discount Edit Page', type: :feature do
  let!(:merchant_1) {Merchant.create!(name: 'Merchant 1', status: 0)}

  let!(:fifteen_off_ten) {merchant_1.bulk_discounts.create!(name: "Fifteen Off Ten", threshold: 10, percent_discount: 15)}

  before(:each) do
    visit edit_merchant_bulk_discount_path(merchant_1.id, fifteen_off_ten.id)
  end

  context 'As a merchant I navigate to the bulk discount edit page' do
    scenario 'and I see an edit form with current attributes prepopulated' do
      expect(page).to have_field('Name', with: "Fifteen Off Ten")
      expect(page).to have_field('Percent Discount', with: "15")
      expect(page).to have_field('Min. Number of Items', with: "10")
      expect(page).to have_button('Update Discount')
    end

    scenario 'I change any/all of the information and submit and am redirected to show page where I see changes' do
      fill_in 'Name', with: 'Updated Name'
      fill_in 'Percent Discount', with: '50'
      fill_in 'Min. Number of Items', with: '25'

      click_button 'Update Discount'

      expect(current_path).to eq(merchant_bulk_discount_path(merchant_1.id, fifteen_off_ten.id))

      expect(page).to have_content('Updated Name')
      expect(page).to have_content(50)
      expect(page).to have_content(25)
    end

    scenario 'If I input invalid data it does not persist to the database' do
      fill_in 'Name', with: 'Updated Name'
      fill_in 'Percent Discount', with: '500'
      fill_in 'Min. Number of Items', with: '25'

      click_button 'Update Discount'

      expect(current_path).to eq(merchant_bulk_discount_path(merchant_1.id, fifteen_off_ten.id))

      expect(page).to have_no_content('Updated Name')
      expect(page).to have_no_content(500)
      expect(page).to have_no_content(25)

      expect(page).to have_content('Fifteen Off Ten')
      expect(page).to have_content(15)
      expect(page).to have_content(10)
    end
  end
end
