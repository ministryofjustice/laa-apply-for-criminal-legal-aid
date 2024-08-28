module Steps
  module Income
    class ArmedForcesForm < Steps::BaseFormObject
      include Steps::HasOneAssociation

      attr_accessor :subject

      has_one_association :income

      attribute :in_armed_forces, :value_object, source: YesNoAnswer

      validate :in_armed_forces_choice

      def initialize(attributes = {})
        super
        return if in_armed_forces.present?

        current_val = income.send(subject_attribute)
        assign_attributes(in_armed_forces: YesNoAnswer.new(current_val)) if current_val.present?
      end

      def persist!
        record.update(subject_attribute => in_armed_forces)
      end

      def choices
        YesNoAnswer.values
      end

      def form_subject
        SubjectType.new(subject.ownership_type)
      end

      private

      def subject_attribute
        :"#{form_subject.to_param}_in_armed_forces"
      end

      def in_armed_forces_choice
        return if in_armed_forces.in?(YesNoAnswer.values)

        errors.add(:in_armed_forces, :inclusion, subject: form_subject.to_param)
      end
    end
  end
end
