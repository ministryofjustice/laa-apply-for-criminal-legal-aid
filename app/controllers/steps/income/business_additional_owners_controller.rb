module Steps
  module Income
    class BusinessAdditionalOwnersController < Steps::BaseStepController
      include SubjectResource
      include BusinessResource

      def edit
        @form_object = BusinessAdditionalOwnersForm.build(
          business_record,
          crime_application: current_crime_application
        )
      end

      def update
        update_and_advance(
          BusinessAdditionalOwnersForm,
          record: business_record,
          as: :business_additional_owners
        )
      end
    end
  end
end
