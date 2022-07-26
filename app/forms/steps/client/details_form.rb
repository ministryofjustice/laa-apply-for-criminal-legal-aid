module Steps
  module Client
    class DetailsForm < Steps::BaseFormObject
      include Steps::HasOneAssociation

      has_one_association :applicant_details

      attribute :first_name, :string
      attribute :last_name, :string
      attribute :other_names, :string
      attribute :date_of_birth, :multiparam_date

      validates_presence_of :first_name,
                            :last_name

      validates :date_of_birth, presence: true, multiparam_date: true

      private

      def persist!
        applicant_details.update(
          attributes
        )
      end
    end
  end
end
