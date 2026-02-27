module Steps
  module Case
    class IsClientRemandedForm < Steps::BaseFormObject
      include Steps::HasOneAssociation

      has_one_association :case

      attribute :is_client_remanded, :value_object, source: YesNoAnswer
      attribute :date_client_remanded, :multiparam_date

      validates_inclusion_of :is_client_remanded, in: :choices

      validates :date_client_remanded,
                multiparam_date: true,
                presence: true,
                if: -> { client_remanded? }

      def choices
        YesNoAnswer.values
      end

      private

      def persist!
        self.case.update(
          attributes.merge(attributes_to_reset)
        )
      end

      def attributes_to_reset
        {
          'date_client_remanded' => (date_client_remanded if client_remanded?)
        }
      end

      def client_remanded?
        is_client_remanded&.yes?
      end
    end
  end
end
