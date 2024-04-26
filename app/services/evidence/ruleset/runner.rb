module Evidence
  module Ruleset
    class Runner
      RULES_DIR = Rails.root.join('app/services/evidence/rules/*').freeze

      # WARNING: DO NOT DELETE EXISTING KEYS, ADD NEW UNIQUE KEY INSTEAD
      # DELETING A KEY COULD CAUSE SUBMITTED APPLICATIONS TO USE INCORRECT RULES!
      # Controls which rules are executed for a fresh CrimeApplication
      # Determines order of output on the Evidence Upload page
      # In effect the KEYS are the ruleset to be executed. Having a different
      # KEY list would generate a different ruleset, allowing ruleset versioning.
      #
      # When a new rule is created add the key to this list
      KEYS = %i[
        # Income
        income_employed_0a
        income_benefits_0b
        income_p60_sa302_2
        income_selfemployed_3
        income_noncash_benefit_4
        income_private_pension_5
        income_maintenance_6
        income_investments_7
        income_rent_8
        income_other_9

        # Outgoings
        outgoings_housing_11
        outgoings_counciltax_12
        outgoings_childcare_14
        outgoings_maintenance_15

        # Other
        national_insurance_32
      ].freeze

      attr_reader :crime_application

      def initialize(crime_application)
        @crime_application = crime_application
        raise ArgumentError, 'CrimeApplication required' unless @crime_application

        self.class.load_rules!
        validate!
      end

      # NOTE: The MTR process due in 2024 may result in providers being allowed to select
      # whether to use the latest ruleset or select more amenable versions of changed rules.
      def ruleset
        @ruleset ||=
          if !Array.wrap(crime_application.evidence_prompts).empty? && crime_application.resubmission?
            Ruleset::Hydrated.new(crime_application, keys)
          else
            Ruleset::Latest.new(crime_application, keys)
          end
      end

      def keys
        KEYS
      end

      # NOTE: Manually checking if Evidence::Rules modules have been loaded
      # rather than relying on using `require`. Rails seems to have the filepaths
      # for /rules/* in $LOADED_FEATURES even though there is the autoload exception
      # in zeitwerk.rb. Trying to prevent repeated loading (and possible SimpleCov
      # inaccurate results)
      def self.load_rules!
        return if Evidence.constants.include?(:Rules)

        Dir.glob(RULES_DIR).each { |file| load file }
      end

      private

      def validate!
        ruleset.each do |rule|
          raise ArgumentError, "Rule #{rule} is not valid" unless rule.valid?
        end
      end
    end
  end
end
