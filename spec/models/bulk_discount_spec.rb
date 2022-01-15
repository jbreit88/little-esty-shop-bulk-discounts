require 'rails_helper'

RSpec.describe BulkDiscount, type: :model do
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
end
