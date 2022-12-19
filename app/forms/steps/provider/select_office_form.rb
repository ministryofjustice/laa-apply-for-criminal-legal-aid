module Steps
  module Provider
    class SelectOfficeForm < Steps::BaseFormObject
      attribute :office_code, :string
      validates :office_code, inclusion: { in: :choices }

      def choices
        record.office_codes
      end

      private

      def persist!
        record.update(
          selected_office_code: office_code
        )
      end
    end
  end
end
