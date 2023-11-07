require 'clamby'
require 'laa_crime_schemas'
require 'open3'

# Performs virus scan using remote ClamAV scanning server
module Datastore
  module Documents
    class Scan
      TIMEOUT = 10 # Seconds before ClamAV scan abandoned

      attr_reader :document

      def initialize(document:)
        @document = document
      end

      def call
        raise ArgumentError, 'Document not present' if document.nil?

        document.update(
          scan_status: scan_result,
          scan_at: ::Time.current,
          scan_provider: 'ClamAV'
        )

        Rails.logger.info "Document scan attempted. Result: `#{document.scan_status}`"

        success?
      end

      def success?
        [type_of('pass')].include? document.scan_status
      end

      # Likely states if ClamAV server not found
      def inconclusive?
        [type_of('awaiting'), type_of('other'), type_of('incomplete')].include? document.scan_status
      end

      def failed?
        [type_of('flagged')].include? document.scan_status
      end

      # See specs for expected STDOUT/STDERR outputs
      def unavailable?
        stdout, stderr, _status = Open3.capture3('clamdscan', '-c', Clamby.config[:config_file], '--version')
        !(stdout.to_s.include?('ClamAV') && stderr.to_s.blank?)
      rescue Errno::ENOENT => e
        log = [
          'ClamAV Error - clamdscan package must be installed and executable',
          "Exception: #{e.message}"
        ].join(' ')
        Rails.logger.error(log)
        true
      end

      private

      def scan_result # rubocop:disable Metrics/MethodLength
        if unavailable?
          Rails.logger.error('ClamAV Scan Service unavailable')
          return type_of('other')
        end

        Rails.error.handle(fallback: -> { type_of('incomplete') }) do
          Timeout.timeout(TIMEOUT, "ClamAV file scan breached #{TIMEOUT} seconds, scan abadoned") do
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

      def type_of(key)
        ::LaaCrimeSchemas::Types::VirusScanStatus[key]
      end
    end
  end
end
