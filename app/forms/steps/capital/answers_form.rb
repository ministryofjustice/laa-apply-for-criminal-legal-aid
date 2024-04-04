module Steps
  module Capital
    class AnswersForm < Steps::BaseFormObject
      attribute :has_no_other_assets

      validates :has_no_other_assets, presence: true
      validates :has_no_other_assets, inclusion: { in: [YesNoAnswer::YES.to_s] }

      def persist!
        record.update(attributes)
      end
    end
  end
end
