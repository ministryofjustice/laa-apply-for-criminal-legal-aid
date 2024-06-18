module Steps
  module Income
    module EmploymentUpdateStep
      extend ActiveSupport::Concern

      def edit
        @form_object = form_name.build(
          employment_record, crime_application: current_crime_application
        )
      end

      def update
        update_and_advance(
          form_name, record: employment_record, as: advance_as, flash: flash_msg
        )
      end

      private

      def employment_record
        @employment_record ||= employments.find(params[:employment_id])
      rescue ActiveRecord::RecordNotFound
        raise Errors::EmploymentNotFound
      end

      # :nocov:
      def employments
        raise NotImplementedError
      end

      def advance_as
        raise NotImplementedError
      end

      def form_name
        raise NotImplementedError
      end

      def flash_msg
        nil
      end
      # :nocov:
    end
  end
end
