module Slipstream
  class PersistSelectionOutcome
    def initialize(crime_application)
      @crime_application = crime_application
      @sample_rate = Settings.slipstream_audit.fetch(:sample_rate)
      @selector = CandidateSelector.new(crime_application, sample_rate: @sample_rate)
    end

    def call
      crime_application.with_lock do
        existing_outcome = SlipstreamAuditSelectionOutcome.find_by(crime_application:)
        return existing_outcome if existing_outcome

        status = selector.call
        return unless status

        persist(status)
      end
    end

    private

    attr_reader :crime_application, :sample_rate, :selector

    def persist(status)
      sampled_at = Time.current

      crime_application.create_slipstream_audit_selection_outcome!(
        status: status,
        sample_rate: sample_rate,
        sampled_at: sampled_at,
        status_determined_at: sampled_at
      )
    end
  end
end
