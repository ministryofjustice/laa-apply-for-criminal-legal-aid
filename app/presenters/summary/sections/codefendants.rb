module Summary
  module Sections
    class Codefendants < Sections::BaseSection
      def show?
        kase.present? && super
      end

      def answers
        return codefendants_component unless no_codefendants?

        [
          Components::ValueAnswer.new(
            :has_codefendants, kase.has_codefendants,
            change_path: edit_steps_case_has_codefendants_path
          )
        ]
      end

      def list?
        !no_codefendants?
      end

      private

      def codefendants_component
        Components::Codefendant.with_collection(
          codefendants, show_actions: editable?, show_record_actions: headless?
        )
      end

      def codefendants
        @codefendants ||= kase.codefendants
      end

      def no_codefendants?
        kase.has_codefendants.to_s == 'no'
      end
    end
  end
end
