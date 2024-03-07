class RemoveCouncilTaxAmountFieldFromOutgoings < ActiveRecord::Migration[7.0]
  def up
    Outgoings.transaction do
      Outgoings
        .where("pays_council_tax = 'yes' AND council_tax_amount IS NOT NULL")
        .in_batches(of: 100)
        .each_record do |outgoing|
          OutgoingsPayment.create!(
            crime_application_id: outgoing.crime_application_id,
            payment_type: OutgoingsPaymentType::COUNCIL_TAX.value,
            amount: outgoing.council_tax_amount,
            frequency: PaymentFrequencyType::ANNUALLY,
          )
      end
    end

    remove_column :outgoings, :council_tax_amount
  end

  def down
    add_column :outgoings, :council_tax_amount, :bigint, default: nil

    Outgoings.transaction do
      outgoing_payments = OutgoingsPayment
        .where(payment_type: OutgoingsPaymentType::COUNCIL_TAX)
        .joins("INNER JOIN outgoings ON outgoings.crime_application_id = outgoings_payments.crime_application_id AND outgoings.pays_council_tax = 'yes'")
        .in_batches(of: 100)

      outgoing_payments.each_record do |payment|
        outgoing = Outgoings.find_by(crime_application_id: payment.crime_application_id)
        outgoing.update!(council_tax_amount: payment.amount_before_type_cast)
      end

      outgoing_payments.destroy_all
    end
  end
end
