Rails.application.config.to_prepare do
  # Sentry is enabled if SENTRY_DSN environment variable is set
  Sentry.init do |config|
    config.breadcrumbs_logger = [:active_support_logger, :http_logger]
    config.environment = HostEnv.env_name

    # Opt in to new Rails error reporting API
    # https://edgeguides.rubyonrails.org/error_reporting.html
    config.rails.register_error_subscriber = true

    # Filtering
    # https://docs.sentry.io/platforms/ruby/guides/rails/configuration/filtering/

    config.data_collection.user_info = false
    config.data_collection.cookies = false
    config.data_collection.http_headers.request.mode = :deny_list
    config.data_collection.http_headers.request.terms = Sentry::DataCollection::PII_HEADER_SNIPPETS
    config.data_collection.http_headers.response.mode = :deny_list
    config.data_collection.http_headers.response.terms = Sentry::DataCollection::PII_HEADER_SNIPPETS
    config.data_collection.http_bodies = []
    config.data_collection.url_query_params = false
    config.data_collection.graphql.document = false
    config.data_collection.graphql.variables = false
    config.data_collection.database_query_data = false
    config.data_collection.queues = false
    config.data_collection.stack_frame_variables = false

    params_filter = ActiveSupport::ParameterFilter.new(
      Rails.application.config.filter_parameters
    )
    config.before_send = lambda do |event, _hint|
      if event.request
        event.request.data = params_filter.filter(event.request.data) if event.request.data
        event.request.cookies = params_filter.filter(event.request.cookies) if event.request.cookies
      end

      if event.user
        event.user = params_filter.filter(event.user)
      end

      event
    end
  end
end

# We also want to log the exception, to be aware
Rails.application.config.after_initialize do
  Rails.error.subscribe(LoggerErrorSubscriber.new)
end
