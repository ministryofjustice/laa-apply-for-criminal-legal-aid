require 'clamby'
require 'laa_crime_schemas'
require 'open3'

# Performs virus scan using remote ClamAV scanning server
module Datastore
  module Documents
    class Scan
      class ScanError < StandardError; end

      TIMEOUT = ENV.fetch('VIRUS_SCAN_TIMEOUT', 20).to_i # Seconds before ClamAV scan abandoned
      MIN_TIMEOUT = 5

      attr_reader :document

      delegate :success?, :flagged?, :inconclusive?, to: :class

      def initialize(document:)
        @document = document
      end

      def call
        raise ScanError, t(:document_missing) if document.nil?
        raise ScanError, t(:bad_timeout, min: MIN_TIMEOUT, current: TIMEOUT) if TIMEOUT.to_i < MIN_TIMEOUT

        document.update!(
          scan_status: scan_result,
          scan_at: ::Time.current,
          scan_provider: 'ClamAV'
        )

        Rails.logger.info t(:attempted, scan_status: document.scan_status)

        success?
      end

      def success?
        self.class.success?(document)
      end

      def inconclusive?
        self.class.inconclusive?(document)
      end

      def flagged?
        self.class.flagged?(document)
      end

      delegate :type_of, to: :class

      # See specs for expected STDOUT/STDERR outputs
      def unavailable?
        stdout, stderr, _status = Open3.capture3('clamdscan', '-c', Clamby.config[:config_file], '--version')
        !(stdout.to_s.include?('ClamAV') && stderr.to_s.blank?)
      rescue Errno::ENOENT => e
        Rails.logger.error t(:not_installed, message: e.message)
        true
      end

      class << self
        def success?(document)
          [type_of('pass')].include? document.scan_status
        end

        def flagged?(document)
          [type_of('flagged')].include? document.scan_status
          document.scan_status == type_of('flagged')
        end

        # Likely states if ClamAV server not found
        def inconclusive?(document)
          [type_of('awaiting'), type_of('other'), type_of('incomplete')].include? document.scan_status
        end

        def type_of(key)
          ::Types::VirusScanStatus[key]
        end
      end

      private

      def scan_result # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
        if unavailable?
          Rails.logger.error t(:unavailable)
          return type_of('other')
        end

        Rails.error.handle(fallback: -> { type_of('incomplete') }) do
          Timeout.timeout(TIMEOUT, t(:timeout, timeout: TIMEOUT)) do
            case Clamby.safe?(document.tempfile.path)
            when true
              type_of('pass')
            when false
              type_of('flagged')
            else
              type_of('other')
            end
          end
        end
      end

      def t(key, **args)
        I18n.t("steps.evidence.scan.#{key}", **args)
      end
    end
  end
end
