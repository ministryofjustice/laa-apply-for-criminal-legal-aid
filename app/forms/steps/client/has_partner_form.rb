module Steps
  module Client
    class HasPartnerForm < Steps::BaseFormObject
      attribute :client_has_partner, :yes_no

      validates_inclusion_of :client_has_partner, in: :choices

      def choices
        YesNoAnswer.values
      end

      private

      def persist!
        crime_application.update(
          attributes.merge(status: ApplicationStatus::IN_PROGRESS.to_s)
        )
      end
    end
  end
end
