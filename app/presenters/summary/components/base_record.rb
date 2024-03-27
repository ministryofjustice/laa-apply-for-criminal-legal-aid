module Summary
  module Components
    class BaseRecord < ViewComponent::Base
      with_collection_parameter :record

      attr_reader :record, :record_iteration, :show_actions

      def initialize(record:, record_iteration: nil, show_actions: true)
        @record = record
        @record_iteration = record_iteration
        @show_actions = show_actions

        super
      end

      def call
        govuk_summary_card(title:) do |card|
          if show_actions
            card.with_action { change_link }
            card.with_action { remove_link }
          end

          govuk_summary_list do |list|
            answers.each do |answer|
              list.with_row do |row|
                row.with_key { answer.question_text }
                row.with_value { answer.answer_text }
              end
            end
          end
        end
      end

      # Human model name of the record. Override in subclass if name is not based
      # on the component.
      # see Summary::Components::Saving where name is based on the saving_type.
      def name
        record.model_name.human
      end

      def title
        safe_join([status_tag, name, count].compact, ' ')
      end

      def change_link
        govuk_link_to(
          'Change',
          change_path,
          visually_hidden_suffix: name,
          no_visited_state: true
        )
      end

      def remove_link
        govuk_link_to(
          'Remove',
          remove_path,
          visually_hidden_suffix: name,
          no_visited_state: true
        )
      end

      private

      # :nocov:
      def answers
        raise 'must be implemented in subclasses'
      end

      def change_path
        raise 'must be implemented in subclasses'
      end

      def remove_path
        raise 'must be implemented in subclasses'
      end
      # :nocov:

      def count
        return unless record_iteration
        return unless record_iteration.size > 1

        record_iteration.index + 1
      end

      def status_tag
        return if record.complete?

        GovukComponent::TagComponent.new(
          text: :incomplete,
          colour: 'red'
        ).call
      end
    end
  end
end
