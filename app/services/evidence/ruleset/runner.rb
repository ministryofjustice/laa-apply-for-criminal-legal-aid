module Evidence
  module Ruleset
    class Runner
      RULES_DIR = Rails.root.join('app/services/evidence/rules/*').freeze

      # WARNING: DO NOT DELETE EXISTING KEYS, ADD NEW UNIQUE KEY INSTEAD
      # DELETING A KEY COULD CAUSE SUBMITTED APPLICATIONS TO USE INCORRECT RULES!
      # Controls which rules are executed for a fresh CrimeApplication
      # Determines order of output on the Evidence Upload page
      KEYS = %i[
        p45_proof_33
        national_insurance_32
      ].freeze

      attr_reader :crime_application

      def initialize(crime_application)
        @crime_application = crime_application

        load_rule_definitions
        validate!
      end

      def prompt
        @prompt ||= Prompt.new(ruleset)
      end

      # NOTE: The MTR process due in 2024 may result in providers being allowed to select
      # whether to use the latest ruleset or select more amenable versions of changed rules.
      def ruleset
        @ruleset ||=
          if !Array.wrap(crime_application.evidence_ruleset).empty? && crime_application.resubmission?
            Ruleset::Hydrated.new(crime_application, keys)
          else
            Ruleset::Latest.new(crime_application, keys)
          end
      end

      def keys
        KEYS
      end

      private

      def load_rule_definitions
        Dir.glob(RULES_DIR).each { |file| load file }
      end

      def validate!
        ruleset.each do |rule|
          raise ArgumentError, "Rule #{rule} is not valid" unless rule.valid?
        end
      end
    end
  end
end
