module Steps
  module Income
    module Partner
      class EmploymentsSummaryForm < Steps::Income::Client::EmploymentsSummaryForm
        attr_reader :add_partner_employment

        validates_inclusion_of :add_partner_employment, in: :choices

        delegate :partner_employments, to: :crime_application

        def add_partner_employment=(attribute)
          return unless attribute

          @add_partner_employment = YesNoAnswer.new(attribute)
        end
      end
    end
  end
end
