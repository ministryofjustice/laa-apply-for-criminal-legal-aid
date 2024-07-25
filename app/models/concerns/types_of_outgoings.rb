module TypesOfOutgoings
  extend ActiveSupport::Concern

  OutgoingsPaymentType::VALUES.each do |payment_type|
    define_method(payment_type.to_s) do
      outgoings_payments.find do |p|
        OutgoingsPaymentType.new(p.payment_type) == payment_type
      end
    end
  end
end
