module Steps
  module Capital
    class SavingsForm < Steps::BaseFormObject
      attribute :account_balance, :pence
      attribute :provider_name, :string

      def persist!
        record.update(attributes)
      end
    end
  end
end
