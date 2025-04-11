class HealthcheckController < BareApplicationController
  def show
    render json: { healthcheck: healthcheck_result }, status: http_status
  end

  def readiness
    return head :service_unavailable unless database_connected?

    head :ok
  end

  def startup
    return head :service_unavailable unless database_connected?
    return head :service_unavailable unless virus_scan_ready?

    head :ok
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
    ActiveRecord::Base.connection.execute('SELECT 1').present?
  rescue StandardError => e
    Rails.logger.warn("Database health check failed: #{e.message}")

    false
  end

  def virus_scan_ready?
    Rails.cache.fetch('virus_scan_health_check', expires_in: 1.second) do
      Clamby.safe?(virus_scan_test_file.to_s)
    end
  rescue StandardError => e
    Rails.logger.warn("Virus scan health check failed: #{e.message}")

    false
  end

  def virus_scan_test_file
    file = Rails.root.join('tmp/virus_scan_test.txt')

    File.write(file, 'Virus scan health check test') unless File.exist?(file)

    file
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
