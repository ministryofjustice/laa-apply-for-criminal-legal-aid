module Steps
  module Partner
    class DetailsForm < Steps::BaseFormObject
      include Steps::HasOneAssociation
      has_one_association :partner

      attribute :first_name, :string
      attribute :last_name, :string
      attribute :other_names, :string
      attribute :date_of_birth, :multiparam_date

      validates_presence_of :first_name, :last_name

      validates :date_of_birth, presence: true, multiparam_date: true

      private

      def persist!
        return true unless changed?

        partner.update!(attributes)
      end
    end
  end
end
