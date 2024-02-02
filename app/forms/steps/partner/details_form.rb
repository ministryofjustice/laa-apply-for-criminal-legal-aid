module Steps
  module Partner
    class DetailsForm < Steps::BaseFormObject
      include Steps::HasOneAssociation
      has_one_association :partner

      attribute :first_name, :string
      attribute :last_name, :string
      attribute :other_names, :string
      attribute :date_of_birth, :multiparam_date

      validates_presence_of :first_name,
                            :last_name

      validates :date_of_birth, presence: true, multiparam_date: true

      validate :date_of_birth_ten_or_more_years_ago

      private

      def date_of_birth_ten_or_more_years_ago
        return unless date_of_birth.is_a?(Date)

        errors.add(:date_of_birth, :client_under_ten) if date_of_birth.beginning_of_day > 10.years.ago
      end

      def persist!
        return true unless changed?

        # throw partner

        partner.update(
          attributes
        )
      end

      # If the last name or date of birth have changed, the DWP check
      # needs to run again as its result is linked to these attributes
      def attributes_to_reset
        return {} unless changed?(:last_name, :date_of_birth)

        {
          has_nino: nil,
          nino: nil,
          benefit_type: nil,
          passporting_benefit: nil,
        }
      end
    end
  end
end
