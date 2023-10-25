require 'clamby'
require 'laa_crime_schemas'

# Performs virus scan using remote ClamAV scanning server
module Datastore
  module Documents
    class Scan
      # include ::LaaCrimeSchemas::Types

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

        success?
      end

      private

      def success?
        [::LaaCrimeSchemas::Types::VirusScanStatus['pass']].include? document.scan_status
      end

      def scan_result
        Rails.error.handle(fallback: -> { ::LaaCrimeSchemas::Types::VirusScanStatus['incomplete'] }) do
          case Clamby.safe?(document.tempfile.path)
          when true
            ::LaaCrimeSchemas::Types::VirusScanStatus['pass']
          when false
            ::LaaCrimeSchemas::Types::VirusScanStatus['flagged']
          else
            ::LaaCrimeSchemas::Types::VirusScanStatus['other']
          end
        end
      end
    end
  end
end
