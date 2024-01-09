module Steps
  module Client
    class IsMeansTestedController < Steps::ClientStepController
      def edit
        @form_object = IsMeansTestedForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(IsMeansTestedForm, as: :is_means_tested)
      end
    end
  end
end
