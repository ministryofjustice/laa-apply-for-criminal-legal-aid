module Steps
  module Client
    class HasPartnerForm < Steps::BaseFormObject
      attribute :client_has_partner, :value_object, source: YesNoAnswer

      validates_inclusion_of :client_has_partner, in: :choices

      def choices
        YesNoAnswer.values
      end

      private

      def persist!
        crime_application.update(
          attributes
        )
      end
    end
  end
end
