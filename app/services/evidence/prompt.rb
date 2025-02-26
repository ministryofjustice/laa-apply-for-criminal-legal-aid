module Evidence
  class Prompt
    attr_reader :crime_application, :ruleset, :exempt_reasons

    def initialize(crime_application, ruleset = nil)
      @crime_application = crime_application
      raise ArgumentError, 'CrimeApplication required' unless @crime_application

      @ruleset = ruleset || ::Evidence::Ruleset::Runner.new(crime_application).ruleset
      raise Errors::InvalidRuleset, 'Ruleset must provide rule definitions' unless @ruleset.respond_to?(:each)

      @exempt_reasons = []
    end

    def run(ignore_exempt: true)
      exempt! unless ignore_exempt
      results

      self
    end

    def run!(ignore_exempt: true)
      exempt! unless ignore_exempt
      results

      ::CrimeApplication.transaction do
        crime_application.evidence_prompts = @results
        crime_application.evidence_last_run_at = DateTime.now

        crime_application.save!
      end

      self
    end

    # Check `#required?` for any rule predicates that evaluated to true
    def required?
      return false if exempt?

      run
      results?
    end

    def exempt!
      @results = [] if exempt?
    end

    # Partner evidence exempted per rule because it is not a reason to
    # skip prompt result generatation.
    #
    # See Rule#partner_evidence_exempt?
    def exempt?
      @exempt_reasons = []

      [
        under18?,
        not_means_tested?
      ].any?(true)
    end

    def result_for?(group:, persona:)
      result_for(group:, persona:).any?
    end

    def result_for(group:, persona:)
      results.select { |r| (r[:group] == group.to_sym) && (r[:run][persona.to_sym][:result] == true) }
    end

    def results?
      Array.wrap(@results).any? do |prompt|
        prompt[:run].any? { |_persona, predicate| predicate[:result] == true }
      end
    end

    # If exempt! has been run then @results will already be set
    # and therefore the ruleset will never be executed which may
    # not be very useful?
    def results
      @results ||= ruleset.map do |rule|
        rule.new(crime_application).to_h.merge(
          ruleset: ruleset.to_s,
        )
      end
    end

    private

    def not_means_tested?
      return false unless crime_application.not_means_tested?

      @exempt_reasons << I18n.t('evidence.exempt.not_means_tested')

      true
    end

    def under18?
      return false unless crime_application.age_passported?

      @exempt_reasons << I18n.t('evidence.exempt.under_18')

      true
    end
  end
end
