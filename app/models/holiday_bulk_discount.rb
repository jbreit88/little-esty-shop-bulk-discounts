class HolidayBulkDiscount < BulkDiscount

  def self.existing_holiday_discounts
    pluck(:holiday)
    .uniq
  end
end
