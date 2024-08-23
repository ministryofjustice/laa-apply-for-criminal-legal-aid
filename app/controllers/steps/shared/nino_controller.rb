module Steps
  module Shared
    class NinoController < Steps::PartnerStepController
      include SubjectResource

      def edit
        @form_object = Shared::NinoForm.build(
          @subject,
          crime_application: current_crime_application
        )
      end

      def update
        update_and_advance(
          Shared::NinoForm,
          record: @subject,
          as: :nino
        )
      end

      private

      def additional_permitted_params
        [:has_arc_or_nino]
      end

      def decision_tree_class
        return Decisions::PartnerDecisionTree if @subject.instance_of?(::Partner)

        Decisions::ClientDecisionTree
      end
    end
  end
end
