module Steps
  module Income
    module Partner
      class DeductionFieldsetForm < Steps::Income::Client::DeductionFieldsetForm
        def employment
          crime_application.partner_employments.find(employment_id)
        end

        private

        def details_only_when_other?
          if (deduction_type == DeductionType::OTHER.to_s) && details.blank?
            errors.add(:details, :blank)
          elsif (deduction_type != DeductionType::OTHER.to_s) && details.present?
            errors.add(:details, :invalid)
          end
        end
      end
    end
  end
end
