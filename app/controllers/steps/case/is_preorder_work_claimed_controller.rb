module Steps
  module Case
    class IsPreorderWorkClaimedController < Steps::CaseStepController
      def edit
        @form_object = IsPreorderWorkClaimedForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(IsPreorderWorkClaimedForm, as: :is_preorder_work_claimed)
      end
    end
  end
end
