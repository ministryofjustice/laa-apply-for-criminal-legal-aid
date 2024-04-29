module Steps
  module Capital
    class SavingTypeForm < Steps::BaseFormObject
      include Steps::HasOneAssociation
      has_one_association :capital

      attr_writer :saving_type

      validates :saving_type, presence: true
      validates :saving_type, inclusion: { in: SavingType.values.map(&:to_s) << 'none' }
      validates :has_no_savings, inclusion: { in: ['yes', nil] }

      attr_reader :saving

      def choices
        SavingType.values
      end

      def saving_type
        return @saving_type if @saving_type

        'none' if capital.has_no_savings == 'yes'
      end

      def has_no_savings
        'yes' if saving_type == 'none'
      end

      private

      def persist!
        capital.update(has_no_savings:)

        return true if saving_type == 'none'

        @saving = incomplete_saving_for_type || crime_application.savings.create!(saving_type:)
      end

      def incomplete_saving_for_type
        return nil unless saving_type

        crime_application.savings.where(saving_type:).reject(&:complete?).first
      end
    end
  end
end
