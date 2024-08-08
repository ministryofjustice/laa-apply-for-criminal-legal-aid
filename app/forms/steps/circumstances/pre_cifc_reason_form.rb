module Steps
  module Circumstances
    class PreCifcReasonForm < Steps::BaseFormObject
      attribute :pre_cifc_reason, :string

      validates :pre_cifc_reason, presence: true

      private

      def persist!
        crime_application.update(attributes)
      end
    end
  end
end
