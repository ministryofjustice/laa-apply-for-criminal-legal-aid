module Steps
  module Case
    class FirstCourtHearingForm < Steps::BaseFormObject
      include Steps::HasOneAssociation

      has_one_association :case

      attribute :first_court_hearing_name, :string
      validates :first_court_hearing_name, presence: true

      private

      def persist!
        kase.update(
          attributes
        )
      end
    end
  end
end
