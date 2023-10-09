module Evidence
  class Requirements
    attr_reader :crime_application

    # NOTE: we don't have enough detail yet on how best to implement this.
    # The assumption is, along the journey, there will be "check-points" or
    # questions that will make certain evidence mandatory. For now we only
    # have one question that will trigger the evidence upload page.
    # This class is just a simple wrapper to start with.

    def initialize(crime_application)
      @crime_application = crime_application
    end

    def any?
      [benefits?].any?
    end

    def none?
      !any?
    end

    def benefits?
      YesNoAnswer.new(
        applicant&.has_benefit_evidence.to_s
      ).yes?
    end

    private

    def applicant
      @applicant ||= crime_application.applicant
    end
  end
end
