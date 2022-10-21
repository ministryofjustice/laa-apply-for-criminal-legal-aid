module Steps
  module Submission
    class DeclarationForm < Steps::BaseFormObject
      attribute :declaration_signed, :boolean
      validates :declaration_signed, presence: true

      private

      def persist!
        crime_application.update(
          attributes
        )
      end
    end
  end
end
