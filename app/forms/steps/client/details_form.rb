module Steps
  module Client
    class DetailsForm < Steps::BaseFormObject
      include Steps::HasOneAssociation

      has_one_association :applicant_detail

      attribute :first_name, :string
      attribute :last_name, :string
      attribute :other_names, :string

      validates_presence_of :first_name,
                            :last_name

      private

      def persist!
        applicant_detail.update(
          attributes
        )
      end
    end
  end
end
