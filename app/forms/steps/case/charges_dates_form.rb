module Steps
  module Case
    class ChargesDatesForm < Steps::BaseFormObject

      # transient attribute
      attr_accessor :offence_dates_attributes

      validates_with ChargesValidator, unless: :any_marked_for_destruction?

      def offence_dates
        @offence_dates ||= offence_dates_collection.map do |offence_date|
          OffenceDateFieldsetForm.new(offence_date)
        end
      end

      def any_marked_for_destruction?
        offence_dates.any?(&:_destroy)
      end

      def show_destroy?
        offence_dates.size > 1
      end

      private

      def offence_dates_collection
        if offence_dates_attributes
          # This is a params hash in the format:
          # { "0"=>{"date_from(3i)"=>"21", ...}, "1"=>{"date_from(3i)"=>"21", ...} }
          offence_dates_attributes.values
        else
          record.offence_dates.map do |od|
            od.slice(:id, :date_from, :date_to)
          end
        end
      end

      def persist!
        record.update(
          attributes.merge(
            offence_dates_attributes: offence_dates.map(&:attributes)
          )
        )
      end

    end
  end
end
