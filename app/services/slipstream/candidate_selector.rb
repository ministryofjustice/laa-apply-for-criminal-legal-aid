module Slipstream
  # Randomly selects eligible crime applications into the slipstream audit
  # stream. The selection is intended to run once the provider has declared
  # the offence(s), as this determines whether they are asked to provide IoJ
  # justification.
  #
  # Eligibility: the application has a single slipstreamable offence only,
  # i.e. exactly one charge whose offence is slipstreamable.
  # Sample rate: an integer percentage passed by the caller (e.g. 10 means
  # 10% of eligible applications are selected).
  #
  # NOTE: persisting the outcome of the selection is handled separately;
  # this service only decides whether an application should be selected.
  class CandidateSelector
    def initialize(crime_application, sample_rate:)
      @eligibility_checker = EligibilityChecker.new(crime_application)
      @sample_rate = sample_rate
    end

    def call
      return unless eligibility_checker.eligible?

      selected? ? :selected : :not_selected
    end

    private

    attr_reader :eligibility_checker, :sample_rate

    def selected?
      rand(100) < sample_rate
    end
  end
end
