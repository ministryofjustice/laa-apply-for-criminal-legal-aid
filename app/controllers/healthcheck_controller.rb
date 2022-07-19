class HealthcheckController < BareApplicationController
  def show
    render json: { healthcheck: healthcheck_result }, status: http_status
  end

  def ping
    render json: build_args, status: :ok
  end

  private

  def healthcheck_result
    green? ? 'OK' : 'NOT OK'
  end

  def http_status
    green? ? :ok : :service_unavailable
  end

  def green?
    # add more checks as needed:
    # database_connected? && redis_connected etc...
    database_connected?
  end

  def database_connected?
    ActiveRecord::Base.connection.active?
  rescue StandardError
    false
  end

  # Build information exposed in the Dockerfile
  def build_args
    {
      build_date: ENV.fetch('APP_BUILD_DATE', nil),
      build_tag:  ENV.fetch('APP_BUILD_TAG',  nil),
      commit_id:  ENV.fetch('APP_GIT_COMMIT', nil),
    }.freeze
  end
end
