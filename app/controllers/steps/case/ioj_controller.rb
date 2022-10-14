module Steps
  module Case
    class IojController < Steps::CaseStepController
      def edit
        @form_object = IojForm.build(
          ioj_record, crime_application: current_crime_application
        )
      end

      def update
        update_and_advance(IojForm, record: ioj_record, as: :ioj)
      end

      private

      def ioj_record
        current_crime_application.case.ioj || current_crime_application.case.build_ioj
      end

      def additional_permitted_params
        [types: []]
      end
    end
  end
end
