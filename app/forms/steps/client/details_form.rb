module Steps
  module Client
    class DetailsForm < Steps::BaseFormObject
      include Steps::HasOneAssociation
      has_one_association :applicant

      attribute :first_name, :string
      attribute :last_name, :string
      attribute :other_names, :string
      attribute :date_of_birth, :multiparam_date

      validates_presence_of :first_name,
                            :last_name

      validates :date_of_birth, presence: true,
                multiparam_date: { restrict_past_under_ten_years: true }

      private

      def persist!
        return true unless changed?

        applicant.update(
          attributes.merge(
            # The following are dependent attributes that need to be reset
            attributes_to_reset
          )
        )
      end

      # If the last name or date of birth have changed, the DWP check
      # needs to run again as its result is linked to these attributes
      def attributes_to_reset
        return {} unless changed?(:last_name, :date_of_birth)

        {
          has_nino: nil,
          nino: nil,
          passporting_benefit: nil,
        }
      end
    end
  end
end
