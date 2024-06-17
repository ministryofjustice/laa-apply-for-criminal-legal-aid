module Steps
  module Income
    module Partner
      class DeductionFieldsetForm < Steps::Income::Client::DeductionFieldsetForm
        def employment
          crime_application.partner_employments.find(employment_id)
        end
      end
    end
  end
end
