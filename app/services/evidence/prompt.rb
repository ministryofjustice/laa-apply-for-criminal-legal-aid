module Evidence
  class Prompt
    attr_reader :crime_application, :ruleset

    def initialize(crime_application, ruleset = nil)
      @crime_application = crime_application
      raise ArgumentError, 'CrimeApplication required' unless @crime_application

      @ruleset = ruleset || ::Evidence::Ruleset::Runner.new(crime_application).ruleset
      raise InvalidRuleset, 'Ruleset must provide rule definitions' unless @ruleset.respond_to?(:each)
    end

    def dry_run!
      results

      self
    end

    def run!
      results

      ::CrimeApplication.transaction do
        @crime_application.evidence_prompts = @results
        @crime_application.evidence_last_run_at = DateTime.now

        @crime_application.save!
      end

      self
    end

    def required?
      dry_run!

      !@results.empty?
    end

    def result_for?(group:, persona:)
      result_for(group:, persona:).any?
    end

    def result_for(group:, persona:)
      results.select { |r| (r[:group] == group.to_sym) && (r[:run][persona.to_sym][:result] == true) }
    end

    private

    def results
      @results ||= ruleset.map do |rule|
        rule.new(crime_application).to_h.merge(ruleset: ruleset.to_s)
      end
    end
  end
end
