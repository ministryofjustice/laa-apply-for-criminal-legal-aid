Rails.application.config.to_prepare do
  # Sentry is enabled if SENTRY_DSN environment variable is set
  Sentry.init do |config|
    config.traces_sample_rate = 0.05
    config.dsn = 'https://78db26a7cadc95e7dacce11f2852a240@o345774.ingest.us.sentry.io/4507142444023808'
    config.breadcrumbs_logger = [:active_support_logger, :http_logger]
    config.environment = HostEnv.env_name

    # Opt in to new Rails error reporting API
    # https://edgeguides.rubyonrails.org/error_reporting.html
    config.rails.register_error_subscriber = true

    # Filtering
    # https://docs.sentry.io/platforms/ruby/guides/rails/configuration/filtering/

    params_filter = ActiveSupport::ParameterFilter.new(
      Rails.application.config.filter_parameters
    )
    config.before_send = lambda do |event, _hint|
      params_filter.filter(event.to_hash)
    end
  end
end

# We also want to log the exception, to be aware
Rails.application.config.after_initialize do
  Rails.error.subscribe(LoggerErrorSubscriber.new)
end
