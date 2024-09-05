require 'rails_helper'

RSpec.describe SubmissionSerializer::Sections::OutgoingsDetails do
  subject(:serializer) { described_class.new(crime_application) }

  let(:crime_application) {
    instance_double(CrimeApplication, outgoings: outgoings, partner_detail: partner_detail, partner: partner,
  non_means_tested?: false)
  }
  let(:partner_detail) { instance_double(PartnerDetail, involved_in_case:, involvement_in_case:) }
  let(:partner) { instance_double(Partner) }
  let(:involved_in_case) { 'no' }
  let(:involvement_in_case) { nil }

  let(:outgoings) do
    instance_double(
      Outgoings,
      housing_payment_type: 'mortgage',
      income_tax_rate_above_threshold: 'no',
      partner_income_tax_rate_above_threshold: 'no',
      outgoings_more_than_income: 'yes',
      pays_council_tax: 'yes',
      has_no_other_outgoings: nil,
      how_manage: 'A description of how they manage',
      outgoings_payments: outgoings_payments
    )
  end

  let(:outgoings_payments) do
    [
      instance_double(
        OutgoingsPayment,
        payment_type: 'council_tax',
        amount_before_type_cast: 14_744,
        frequency: 'month',
        metadata: {},
      ),
      instance_double(
        OutgoingsPayment,
        payment_type: HousingPaymentType::MORTGAGE,
        amount_before_type_cast: 3_292_900,
        frequency: 'annual',
        metadata: {},
      )
    ]
  end

  before do
    allow(serializer).to receive(:requires_full_means_assessment?).and_return(true)
  end

  describe '#generate' do
    let(:json_output) do
      {
        outgoings: [
          {
            payment_type: 'council_tax',
            amount: 14_744,
            frequency: 'month',
            ownership_type: 'applicant',
            metadata: {},
          },
          {
            payment_type: 'mortgage',
            amount: 3_292_900,
            frequency: 'annual',
            ownership_type: 'applicant',
            metadata: {},
          }
        ],
          housing_payment_type: 'mortgage',
          income_tax_rate_above_threshold: 'no',
          partner_income_tax_rate_above_threshold: 'no',
          outgoings_more_than_income: 'yes',
          how_manage: 'A description of how they manage',
          pays_council_tax: 'yes',
          has_no_other_outgoings: nil
      }.as_json
    end

    it { expect(subject.generate).to eq(json_output) }
  end
end
