module Steps
  module Income
    module Client
      class EmploymentsSummaryForm < Steps::BaseFormObject
        attr_reader :add_client_employment

        validates_inclusion_of :add_client_employment, in: :choices

        delegate :client_employments, to: :crime_application

        def choices
          YesNoAnswer.values
        end

        def add_client_employment=(attribute)
          return unless attribute

          @add_client_employment = YesNoAnswer.new(attribute)
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
