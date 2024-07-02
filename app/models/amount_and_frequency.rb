class AmountAndFrequency
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Serialization

  attribute :amount, :pence
  attribute :frequency, :value_object, source: PaymentFrequencyType

  def as_json(_opts = {})
    attributes
  end
end
