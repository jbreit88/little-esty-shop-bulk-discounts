class HolidayFacade
  attr_reader :service,
              :holidays

  def initialize
    @service = service
  end

  def holidays
    @_holidays ||= service.next_365_us_holidays.map do |data|
      Holiday.new(data)
    end
  end

  def service
    @_service ||= HolidayService.new
  end
end
