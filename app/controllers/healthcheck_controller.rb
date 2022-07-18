# rubocop:disable Rails/ApplicationController
class HealthcheckController < ActionController::Base
  def show
    render json: { healthcheck: healthcheck_result }, status: http_status
  end

  private

  def healthcheck_result
    green? ? 'OK' : 'NOT OK'
  end

  def http_status
    green? ? 200 : 503
  end

  def green?
    # add more checks as needed:
    # database_connected? && redis_connected etc...
    database_connected?
  end

  def database_connected?
    ApplicationRecord.connection.select_value('SELECT 1') == 1
  rescue StandardError
    false
  end
end
# rubocop:enable Rails/ApplicationController
