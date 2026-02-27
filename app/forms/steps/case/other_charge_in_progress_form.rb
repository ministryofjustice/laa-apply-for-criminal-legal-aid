module Steps
  module Case
    class OtherChargeInProgressForm < Steps::BaseFormObject
      include Steps::HasOneAssociation

      has_one_association :case

      attr_accessor :subject

      attribute :other_charge_in_progress, :value_object, source: YesNoAnswer

      validate :other_charge_in_progress_choice

      def initialize(attributes = {})
        super
        return if other_charge_in_progress.present?

        current_val = self.case.send(subject_attribute)
        assign_attributes(other_charge_in_progress: YesNoAnswer.new(current_val)) if current_val.present?
      end

      def persist!
        ::Case.transaction do
          record.update(subject_attribute => other_charge_in_progress)

          other_charge = record.send(:"#{form_subject.to_param}_other_charge")
          if other_charge.nil? && other_charge_in_progress == YesNoAnswer::YES
            OtherCharge.create!(case: record, ownership_type: form_subject.to_s)
          end

          true
        end
      end

      def choices
        YesNoAnswer.values
      end

      def form_subject
        SubjectType.new(subject.ownership_type)
      end

      private

      def subject_attribute
        :"#{form_subject.to_param}_other_charge_in_progress"
      end

      def other_charge_in_progress_choice
        return if other_charge_in_progress.in?(YesNoAnswer.values)

        errors.add(:other_charge_in_progress, :inclusion, subject: form_subject.to_param)
      end
    end
  end
end
