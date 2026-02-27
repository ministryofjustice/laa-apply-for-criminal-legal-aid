module Steps
  module Case
    class IojForm < Steps::BaseFormObject
      include Steps::HasOneAssociation

      has_one_association :ioj, through: :case

      attribute :types, array: true, default: []

      IojReasonType.values.each do |ioj_type|
        attribute ioj_type.justification_field_name, :string
      end

      validate :validate_types

      IojReasonType.values.each do |ioj_type|
        validates ioj_type.justification_field_name,
                  presence: true,
                  if: -> { types.include?(ioj_type.to_s) }
      end

      def types=(ary)
        super(ary.compact_blank) if ary
      end

      private

      def validate_types
        errors.add(:types, :invalid) if types.empty? || (types - IojReasonType.values.map(&:to_s)).any?
      end

      def persist!
        ioj.update(
          attributes.merge(attributes_to_reset)
        )
      end

      def attributes_to_reset
        {
          'loss_of_liberty_justification' => liberty_justification,
          'suspended_sentence_justification' => sentence_justification,
          'loss_of_livelihood_justification' => livelihood_justification,
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

      def livelihood_justification
        types.include?('loss_of_livelihood') ? loss_of_livelihood_justification : nil
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
