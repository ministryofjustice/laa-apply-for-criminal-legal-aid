require 'rails_helper'

describe Summary::Sections::OtherOutgoingsDetails do
  subject { described_class.new(crime_application) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      to_param: '12345',
      outgoings: outgoings,
      partner: partner,
      partner_detail: partner_detail,
      non_means_tested?: false
    )
  end

  let(:outgoings) do
    instance_double(
      Outgoings,
      income_tax_rate_above_threshold: 'no',
      partner_income_tax_rate_above_threshold: 'no',
      outgoings_more_than_income: 'yes',
      how_manage: 'An example of how they manage'
    )
  end

  let(:partner) { nil }
  let(:partner_detail) { nil }

  describe '#name' do
    it { expect(subject.name).to eq(:other_outgoings_details) }
  end

  describe '#show?' do
    context 'when there is an outgoings_details' do
      it 'shows this section' do
        expect(subject.show?).to be(true)
      end
    end

    context 'when there is no outgoings_details' do
      let(:outgoings) { nil }

      it 'does not show this section' do
        expect(subject.show?).to be(false)
      end
    end
  end

  describe '#answers' do
    let(:answers) { subject.answers }

    context 'when there are outgoings details' do
      it 'has the correct rows' do
        expect(answers.count).to eq(3)
        expect(answers[0]).to be_an_instance_of(Summary::Components::ValueAnswer)
        expect(answers[0].question).to eq(:income_tax_rate_above_threshold)
        expect(answers[0].change_path)
          .to match('applications/12345/steps/outgoings/client-paid-income-tax-rate')
        expect(answers[0].value).to eq('no')
        expect(answers[1]).to be_an_instance_of(Summary::Components::ValueAnswer)
        expect(answers[1].question).to eq(:outgoings_more_than_income)
        expect(answers[1].change_path)
          .to match('applications/12345/steps/outgoings/are-outgoings-more-than-income')
        expect(answers[1].value).to eq('yes')
        expect(answers[2]).to be_an_instance_of(Summary::Components::FreeTextAnswer)
        expect(answers[2].question).to eq(:how_manage)
        expect(answers[2].change_path)
          .to match('applications/12345/steps/outgoings/are-outgoings-more-than-income')
        expect(answers[2].value).to eq('An example of how they manage')
      end

      context 'when there are partner outgoings details' do
        let(:partner) { instance_double(Partner) }
        let(:partner_detail) do
          instance_double(
            PartnerDetail,
            involvement_in_case: 'none',
          )
        end

        it 'has the correct rows' do
          expect(answers.count).to eq(4)
          expect(answers[0]).to be_an_instance_of(Summary::Components::ValueAnswer)
          expect(answers[0].question).to eq(:income_tax_rate_above_threshold)
          expect(answers[0].change_path)
            .to match('applications/12345/steps/outgoings/client-paid-income-tax-rate')
          expect(answers[0].value).to eq('no')
          expect(answers[1]).to be_an_instance_of(Summary::Components::ValueAnswer)
          expect(answers[1].question).to eq(:partner_income_tax_rate_above_threshold)
          expect(answers[1].change_path)
            .to match('applications/12345/steps/outgoings/partner-paid-income-tax-rate')
          expect(answers[1].value).to eq('no')
          expect(answers[2]).to be_an_instance_of(Summary::Components::ValueAnswer)
          expect(answers[2].question).to eq(:outgoings_more_than_income)
          expect(answers[2].change_path)
            .to match('applications/12345/steps/outgoings/are-outgoings-more-than-income')
          expect(answers[2].value).to eq('yes')
          expect(answers[3]).to be_an_instance_of(Summary::Components::FreeTextAnswer)
          expect(answers[3].question).to eq(:how_manage)
          expect(answers[3].change_path)
            .to match('applications/12345/steps/outgoings/are-outgoings-more-than-income')
          expect(answers[3].value).to eq('An example of how they manage')
        end
      end
    end
  end
end
