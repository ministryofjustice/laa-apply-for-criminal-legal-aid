module Evidence
  class Prompt
    attr_reader :crime_application, :ruleset

    def initialize(ruleset)
      @ruleset = ruleset
      @crime_application = ruleset.crime_application

      results

      ::CrimeApplication.transaction do
        @crime_application.evidence_ruleset = @ruleset.rules
        @crime_application.evidence_prompts = @results
        @crime_application.evidence_last_run_at = DateTime.now

        @crime_application.save!
      end
    end

    def results
      @results ||= ruleset.map do |rule|
        definition = rule.new(crime_application)

        {
          rule_id: definition.id,
          group: rule.group,
          results: {
            client: definition.client_predicate,
            partner: definition.partner_predicate,
            other: definition.other_predicate,
          }
        }
      end
    end

    def client?(group)
      client(group).any?
    end

    def client(group)
      results.select { |r| (r[:group] == group) && (r[:results][:client] == true) }
    end

    def partner?(group)
      partner(group).any?
    end

    def partner(group)
      results.select { |r| (r[:group] == group) && (r[:results][:partner] == true) }
    end

    def other?
      other.any?
    end

    def other
      results.select { |r| (r[:group] == :none) && (r[:results][:other] == true) }
    end
  end
end
