module Slipstream
  # Randomly selects eligible crime applications into the slipstream audit
  # stream. The selection is intended to run once the provider has declared
  # the offence(s), as this determines whether they are asked to provide IoJ
  # justification.
  #
  # Eligibility: the application has a single slipstreamable offence only,
  # i.e. exactly one charge whose offence is slipstreamable.
  # Sample rate: configurable integer percentage via
  # `Settings.slipstream_audit[:sample_rate]` (e.g. 10 means 10% of
  # eligible applications are selected).
  #
  # NOTE: persisting the outcome of the selection is handled separately;
  # this service only decides whether an application should be selected.
  class CandidateSelector
    attr_reader :crime_application

    def initialize(crime_application)
      @crime_application = crime_application
    end

    def call
      return if FeatureFlags.slipstream_audit.disabled?
      return unless eligible?

      selected? ? :selected : :not_selected
    end

    private

    def eligible?
      charges.one? && charges.all? { |charge| charge.offence&.slipstreamable }
    end

    def selected?
      rand(100) < sample_rate
    end

    def sample_rate
      Settings.slipstream_audit.fetch(:sample_rate)
    end

    def charges
      crime_application.case&.charges.to_a
    end
  end
end
