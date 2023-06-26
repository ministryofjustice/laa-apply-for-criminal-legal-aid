module PrometheusMetrics
  module Configuration
    require 'prometheus_exporter/server'
    require_relative 'collectors'

    DEFAULT_PREFIX = 'ruby_'.freeze
    SERVER_BINDING_HOST = '0.0.0.0'.freeze
    SERVER_BINDING_PORT = 9394

    CUSTOM_COLLECTORS = [
      PrometheusMetrics::ApplicationsCountCollector
    ].freeze

    # :nocov:
    def self.should_configure?
      return false if ENV.key?('SKIP_PROMETHEUS_EXPORTER')

      # For now we only initialise prometheus exporter on servers
      # In the future this may change to also support workers
      return false unless defined?(Rails) &&
                          (Rails.const_defined?('Rails::Server') || File.basename($PROGRAM_NAME) == 'puma')

      ENV.fetch('ENABLE_PROMETHEUS_EXPORTER', 'false').inquiry.true?
    end

    # We are running puma in single process mode, so this is safe
    # If we move to multi process mode, we will have to run the
    # exporter process separately (`bundle exec prometheus_exporter`)
    def self.start_server
      server = PrometheusExporter::Server::WebServer.new(
        bind: SERVER_BINDING_HOST, port: SERVER_BINDING_PORT,
        verbose: ENV.fetch('PROMETHEUS_EXPORTER_VERBOSE', 'false').inquiry.true?
      )

      # Register any custom collectors
      CUSTOM_COLLECTORS.each { |klass| server.collector.register_collector(klass.new) }

      server.start

      true
    rescue Errno::EADDRINUSE
      warn "[PrometheusExporter] Server port `#{SERVER_BINDING_PORT}` already in use."
      false
    end

    def self.configure
      return unless should_configure?
      return unless start_server

      require 'prometheus_exporter/instrumentation'
      require 'prometheus_exporter/middleware'

      Rails.logger.info '[PrometheusExporter] Initialising instrumentation middleware...'

      # Metrics will be prefixed, for example `ruby_http_requests_total`
      PrometheusExporter::Metric::Base.default_prefix = DEFAULT_PREFIX

      # This reports stats per request like HTTP status and timings
      Rails.application.middleware.unshift PrometheusExporter::Middleware

      # This reports basic process stats like RSS and GC info, type master
      # means it is instrumenting the master process
      PrometheusExporter::Instrumentation::Process.start(type: 'master')

      # NOTE: if running Puma in cluster mode, the following
      # instrumentation will need to be changed
      PrometheusExporter::Instrumentation::Puma.start unless PrometheusExporter::Instrumentation::Puma.started?

      # NOTE: if running Puma in cluster mode, the following
      # instrumentation will need to be changed
      PrometheusExporter::Instrumentation::ActiveRecord.start
    end
    # :nocov:
  end
end
