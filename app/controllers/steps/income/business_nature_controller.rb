module Steps
  module Income
    class BusinessNatureController < Steps::BaseStepController
      include SubjectResource
      include BusinessResource

      def edit
        @form_object = BusinessNatureForm.build(
          business_record,
          crime_application: current_crime_application
        )
      end

      def update
        update_and_advance(
          BusinessNatureForm,
          record: business_record,
          as: :business_nature
        )
      end
    end
  end
end
