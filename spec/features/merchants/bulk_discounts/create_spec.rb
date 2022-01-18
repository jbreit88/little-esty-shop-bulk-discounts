require 'rails_helper'

RSpec.describe 'Bulk Discount Create Page', type: :feature do
  let!(:merchant_1) {Merchant.create!(name: 'Merchant 1', status: 0)}

  context 'As a merchant when I visit the discount create page' do
    before(:each) do
      visit new_merchant_bulk_discount_path(merchant_1.id)
    end

    scenario 'I see a form to create a new discount' do
      expect(page).to have_field('Name')
      expect(page).to have_field('Min. Number of Items')
      expect(page).to have_field('Percent Discount')
      expect(page).to have_button('Create New Discount')
    end

    scenario 'When I fill the form with valid data I am redirected to dicount index and see new discount listed' do
      fill_in 'Name', with: 'Fifty off Fifty'
      fill_in 'Percent Discount', with: '50'
      fill_in 'Min. Number of Items', with: '50'

      click_button 'Create New Discount'

      expect(page).to have_content('Fifty off Fifty')
      expect(current_path).to eq(merchant_bulk_discounts_path(merchant_1.id))
    end

    scenario 'When I fill it in with invalid input it does not persist to the database' do
      # Edgecase Testing
      fill_in 'Name', with: 'Fifty off Fifty'
      fill_in 'Percent Discount', with: '150'
      fill_in 'Min. Number of Items', with: '50'

      click_button 'Create New Discount'

      expect(page).to have_no_content('Fifty off Fifty')
      expect(page).to have_no_content('150')
      expect(current_path).to eq(merchant_bulk_discounts_path(merchant_1.id))

      click_link 'Create New Discount'
      expect(current_path).to eq(new_merchant_bulk_discount_path(merchant_1.id))

      fill_in 'Name', with: 'Fifty off Fifty'
      fill_in 'Percent Discount', with: '50'
      fill_in 'Min. Number of Items', with: 'fifty'

      click_button 'Create New Discount'

      expect(page).to have_no_content('Fifty off Fifty')
      expect(page).to have_no_content('fifty')
      expect(current_path).to eq(merchant_bulk_discounts_path(merchant_1.id))
    end
  end
end
