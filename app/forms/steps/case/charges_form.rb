module Steps
  module Case
    class ChargesForm < Steps::BaseFormObject
      attribute :offence_name, :string

      private

      def persist!
        record.update(
          attributes
        )
      end
    end
  end
end
