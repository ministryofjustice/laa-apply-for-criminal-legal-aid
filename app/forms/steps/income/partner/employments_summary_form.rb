module Steps
  module Income
    module Partner
      class EmploymentsSummaryForm < Steps::BaseFormObject
        attr_reader :add_partner_employment

        validates_inclusion_of :add_partner_employment, in: :choices

        delegate :partner_employments, to: :crime_application

        def choices
          YesNoAnswer.values
        end

        def add_partner_employment=(attribute)
          return unless attribute

          @add_partner_employment = YesNoAnswer.new(attribute)
        end

        private

        # NOTE: this step is not persisting anything to DB.
        # We only use `add_employment=` transiently in the decision tree.
        def persist!
          true
        end
      end
    end
  end
end
