class BusinessHoursMiddleware
  BYPASS_EXACT_PATHS = %w[/].freeze
  BYPASS_PREFIX_PATHS = %w[/health /ping /readyz /startupz /cookies /about /errors /assets].freeze

  def initialize(app)
    @app = app
  end

  def call(env)
    return @app.call(env) if bypass_path?(env['PATH_INFO'])
    return @app.call(env) if within_business_hours?

    [503, { 'Content-Type' => 'text/html; charset=utf-8' }, [business_hours_html]]
  end

  private

  def bypass_path?(path)
    BYPASS_EXACT_PATHS.include?(path) ||
      BYPASS_PREFIX_PATHS.any? { |bypass| path.start_with?(bypass) }
  end

  def london
    Time.find_zone('London')
  end

  def within_business_hours?
    !bank_holiday? && within_hours?
  end

  def bank_holiday?(now = london.now)
    bank_holidays = Govuk::BankHolidays.call
    return false if bank_holidays.blank?

    bank_holidays.include?(now.to_date)
  end

  def within_hours?(now = london.now)
    start_time = london.parse(Rails.configuration.x.business_hours.start)
    end_time   = london.parse(Rails.configuration.x.business_hours.end)

    now >= start_time && now < end_time
  end

  def business_hours_html
    @business_hours_html ||= Rails.public_path.join('503.html').read
  end
end
