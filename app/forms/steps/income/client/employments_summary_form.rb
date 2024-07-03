module Steps
  module Income
    module Client
      class EmploymentsSummaryForm < Steps::BaseFormObject
        attr_reader :add_client_employment

        validates_inclusion_of :add_client_employment, in: :choices

        def client_employments
          crime_application.income.client_employments
        end

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
