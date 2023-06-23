module PrometheusMetrics
  module Configuration
    SERVER_BINDING_HOST = '0.0.0.0'.freeze
    SERVER_BINDING_PORT = 9394

    CUSTOM_COLLECTORS = [].freeze

    # :nocov:
    def self.should_configure?
      if File.basename($PROGRAM_NAME) == 'rake' ||
         (defined?(Rails) && (Rails.const_defined?(:Console) || Rails.env.test?)) ||
         ENV.key?('SKIP_PROMETHEUS_EXPORTER')
        false
      else
        ENV.fetch('ENABLE_PROMETHEUS_EXPORTER', 'false').inquiry.true?
      end
    end

    # We are running puma in single process mode, so this is safe
    # If we move to multi process mode, we will have to run the
    # exporter process separately (`bundle exec prometheus_exporter`)
    def self.start_server
      require 'prometheus_exporter/server'

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

    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def self.configure
      return unless should_configure?
      return unless start_server

      require 'prometheus_exporter/instrumentation'
      require 'prometheus_exporter/middleware'

      Rails.logger.info '[PrometheusExporter] Initialising middleware...'

      # This reports stats per request like HTTP status and timings
      Rails.application.middleware.unshift PrometheusExporter::Middleware

      # This reports basic process stats like RSS and GC info, type master
      # means it is instrumenting the master process
      PrometheusExporter::Instrumentation::Process.start(
        type: 'master',
        labels: {
          # Hostname variable identify each pod on kubernetes
          hostname: ENV.fetch('HOSTNAME', 'localhost'),
        }
      )

      # NOTE: if running Puma in cluster mode, the following
      # instrumentation will need to be changed
      unless PrometheusExporter::Instrumentation::Puma.started?
        Rails.logger.info '[PrometheusExporter] Initialising Puma instrumentation...'
        PrometheusExporter::Instrumentation::Puma.start(
          labels: {
            # Hostname env variable identify each pod on kubernetes
            hostname: ENV.fetch('HOSTNAME', 'localhost'),
          }
        )
      end

      # NOTE: if running Puma in cluster mode, the following
      # instrumentation will need to be changed
      Rails.logger.info '[PrometheusExporter] Initialising ActiveRecord instrumentation...'
      PrometheusExporter::Instrumentation::ActiveRecord.start
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
    # :nocov:
  end
end
