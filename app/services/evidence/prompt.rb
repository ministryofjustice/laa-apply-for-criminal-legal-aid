module Evidence
  class Prompt
    attr_reader :crime_application, :ruleset

    def initialize(crime_application, ruleset = nil)
      @crime_application = crime_application
      raise ArgumentError, 'CrimeApplication required' unless @crime_application

      @ruleset = ruleset || ::Evidence::Ruleset::Runner.new(crime_application).ruleset
      raise Errors::InvalidRuleset, 'Ruleset must provide rule definitions' unless @ruleset.respond_to?(:each)
    end

    def run
      results

      self
    end

    def run!
      results

      ::CrimeApplication.transaction do
        crime_application.evidence_prompts = @results
        crime_application.evidence_last_run_at = DateTime.now

        crime_application.save!
      end

      self
    end

    def required?
      run

      @results.any? do |prompt|
        prompt[:run].any? { |_persona, predicate| predicate[:result] == true }
      end
    end

    def result_for?(group:, persona:)
      result_for(group:, persona:).any?
    end

    def result_for(group:, persona:)
      results.select { |r| (r[:group] == group.to_sym) && (r[:run][persona.to_sym][:result] == true) }
    end

    def results
      @results ||= ruleset.map do |rule|
        rule.new(crime_application).to_h.merge(
          ruleset: ruleset.to_s,
        )
      end
    end
  end
end
