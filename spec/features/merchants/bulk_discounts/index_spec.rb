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
      # Sadpath Testing
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

      scenario 'When I click this link it redirects to the index page and the discount is no longer listed' do
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

      context 'Holiday Discounts' do
        scenario 'I see a holiday discounts section' do
          within "#holiday-discounts" do
            expect(page).to have_content("Holiday Discounts")
          end
        end

        scenario 'I see a Create Discount button next to each of the three upcoming holidays' do
          within "#holiday-discounts" do
            within "#holiday-discounts-2022-02-21" do
              expect(page).to have_content("Presidents Day")
              expect(page).to have_button("Create Discount")
            end

            within "#holiday-discounts-2022-04-15" do
              expect(page).to have_content("Good Friday")
              expect(page).to have_button("Create Discount")
            end

            within "#holiday-discounts-2022-05-30" do
              expect(page).to have_content("Memorial Day")
              expect(page).to have_button("Create Discount")
            end
          end
        end

        scenario 'When I click the button I am taken to a new discounts form with fields autopopulated' do
          within "#holiday-discounts-2022-02-21" do
            click_button "Create Discount"
          end

          expect(current_path).to eq(new_merchant_holiday_bulk_discount_path(merchant_1.id))

          expect(page).to have_field("Discount Name", with: "Presidents Day Discount")
          expect(page).to have_field("Percentage Discount", with: "30")
          expect(page).to have_field("Quantity Threshold", with: "2")
        end

        scenario 'The form can be submitted as is' do
          within "#holiday-discounts-2022-02-21" do
            click_button "Create Discount"
          end

          click_button "Create Holiday Discount"

          within "#all-discounts" do
            expect(page).to have_content('Presidents Day Discount')
          end
        end

        scenario 'The form can be altered and submitted' do
          within "#holiday-discounts-2022-02-21" do
            click_button "Create Discount"
          end

          fill_in "Discount Name", with: "Perzy Dent Day Sale"
          fill_in "Percentage Discount", with: "20"
          fill_in "Quantity Threshold", with: "10"

          click_button "Create Holiday Discount"

          within "#all-discounts" do
            expect(page).to have_link("Perzy Dent Day Sale")

            click_link "Perzy Dent Day Sale"
          end

          expect(page).to have_content(20)
          expect(page).to have_content(10)
        end

        scenario 'The form redirects to the index page and displays the newly created discount' do
          within "#holiday-discounts-2022-02-21" do
            click_button "Create Discount"
          end

          click_button "Create Holiday Discount"

          expect(current_path).to eq(merchant_bulk_discounts_path(merchant_1.id))
        end

        scenario 'If I input invalid data into the form, it will not persist to the database' do
          # Sadpath Testing
          within "#holiday-discounts-2022-02-21" do
            click_button "Create Discount"
          end

          fill_in "Discount Name", with: "Perzy Dent Day Sale"
          fill_in "Percentage Discount", with: "150"

          click_button "Create Holiday Discount"

          within "#holiday-discounts" do
            expect(page).to have_no_content("Perzy Dent Day Sale")
          end
        end

        scenario 'After creating a discount for that holiday I see a view discount link instead of create discount button' do
          within "#holiday-discounts-2022-02-21" do
            click_button "Create Discount"
          end

          fill_in "Discount Name", with: "Perzy Dent Day Sale"

          click_button "Create Holiday Discount"

          within "#holiday-discounts" do
            expect(page).to have_link("View Holiday Discount")
            click_link "View Holiday Discount"
          end

          expect(page).to have_content("Perzy Dent Day Sale")
          expect(page).to have_content("Quantity Threshold: 2")
          expect(page).to have_content("Percentage Discount: 30")
        end
      end
    end

    context 'I see an upcoming holidays section' do
      scenario 'and i see the name and date of the next 3 upcoming holidays' do
        expect(page).to have_content("Upcoming Holidays:")

        within "#holidays" do
          expect(page).to have_content("Presidents Day")
          expect(page).to have_content("Good Friday")
          expect(page).to have_content("Memorial Day")
          # Sadpath Testing
          expect(page).to have_no_content("Juneteenth")
        end
      end
    end
  end
end
