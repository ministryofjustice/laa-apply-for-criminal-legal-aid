require 'rails_helper'

RSpec.describe Summary::Sections::PartnerSelfAssessmentTaxBill do
  subject(:section) { described_class.new(crime_application) }

  let(:crime_application) { instance_double(CrimeApplication, to_param: '12345', income: income) }
  let(:income) do
    instance_double(
      Income,
      partner_self_assessment_tax_bill: answer,
      partner_self_assessment_tax_bill_amount: Money.new(123_45),
      partner_self_assessment_tax_bill_frequency: 'month'
    )
  end
  let(:answer) { 'yes' }

  it 'links the yes/no answer to the original page' do
    expect(section.answers.first.change_path).to eq(
      '/applications/12345/steps/income/partner/self-assessment-partner'
    )
  end

  it 'links the payment answer to the payment page' do
    expect(section.answers.last.change_path).to eq(
      '/applications/12345/steps/income/partner/self-assessment-tax-bill-payment'
    )
  end

  context 'when the answer is No' do
    let(:answer) { 'no' }

    it 'only shows the yes/no answer' do
      expect(section.answers.map(&:question)).to eq([:partner_self_assessment_tax_bill])
    end
  end
end
