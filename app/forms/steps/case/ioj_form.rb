module Steps
  module Case
    class IojForm < Steps::BaseFormObject
      attribute :types, array: true, default: []
      attribute :loss_of_liberty_justification, :string
      attribute :suspended_sentence_justification, :string
      attribute :loss_of_livelyhood_justification, :string
      attribute :reputation_justification, :string
      attribute :question_of_law_justification, :string
      attribute :understanding_justification, :string
      attribute :witness_tracing_justification, :string
      attribute :expert_examination_justification, :string
      attribute :interest_of_another_justification, :string
      attribute :other_justification, :string

      validate :validate_types

      validates :loss_of_liberty_justification,
                presence: true,
                if: -> { types.include?('loss_of_liberty') }
      validates :suspended_sentence_justification,
                presence: true,
                if: -> { types.include?('suspended_sentence') }
      validates :loss_of_livelyhood_justification,
                presence: true,
                if: -> { types.include?('loss_of_livelyhood') }
      validates :reputation_justification,
                presence: true,
                if: -> { types.include?('reputation') }
      validates :question_of_law_justification,
                presence: true,
                if: -> { types.include?('question_of_law') }
      validates :understanding_justification,
                presence: true,
                if: -> { types.include?('understanding') }
      validates :witness_tracing_justification,
                presence: true,
                if: -> { types.include?('witness_tracing') }
      validates :expert_examination_justification,
                presence: true,
                if: -> { types.include?('expert_examination') }
      validates :interest_of_another_justification,
                presence: true,
                if: -> { types.include?('interest_of_another') }
      validates :other_justification,
                presence: true,
                if: -> { types.include?('other') }

      private

      def validate_types
        errors.add(:types, :invalid) if !types.is_a?(Array) || types.empty?
      end

      def persist!
        record.update(
          attributes.merge(attributes_to_reset)
        )
      end

      def attributes_to_reset
        {
          'loss_of_liberty_justification' => liberty_justification,
          'suspended_sentence_justification' => sentence_justification,
          'loss_of_livelyhood_justification' => livelyhood_justification,
          'reputation_justification' => rep_justification,
          'question_of_law_justification' => law_justification,
          'understanding_justification' => understand_justification,
          'witness_tracing_justification' => tracing_justification,
          'expert_examination_justification' => expert_justification,
          'interest_of_another_justification' => interest_another_justification,
          'other_justification' => another_justification
        }
      end

      def liberty_justification
        types.include?('loss_of_liberty') ? loss_of_liberty_justification : nil
      end

      def sentence_justification
        types.include?('suspended_sentence') ? suspended_sentence_justification : nil
      end

      def livelyhood_justification
        types.include?('loss_of_livelyhood') ? loss_of_livelyhood_justification : nil
      end

      def rep_justification
        types.include?('reputation') ? reputation_justification : nil
      end

      def law_justification
        types.include?('question_of_law') ? question_of_law_justification : nil
      end

      def understand_justification
        types.include?('understanding') ? understanding_justification : nil
      end

      def tracing_justification
        types.include?('witness_tracing') ? witness_tracing_justification : nil
      end

      def expert_justification
        types.include?('expert_examination') ? expert_examination_justification : nil
      end

      def interest_another_justification
        types.include?('interest_of_another') ? interest_of_another_justification : nil
      end

      def another_justification
        types.include?('other') ? other_justification : nil
      end
    end
  end
end
