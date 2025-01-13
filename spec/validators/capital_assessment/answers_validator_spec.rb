require 'rails_helper'

RSpec.describe CapitalAssessment::AnswersValidator, type: :model do
  subject(:validator) { described_class.new(record:, crime_application:) }

  let(:record) { instance_double(Capital, crime_application:, errors:) }
  let(:crime_application) {
    instance_double(CrimeApplication, income: income, partner_detail: partner_detail, partner: partner,
  non_means_tested?: false)
  }
  let(:income) { instance_double(Income) }
  let(:partner_detail) { instance_double(PartnerDetail, involvement_in_case:) }
  let(:partner) { nil }
  let(:errors) { double(:errors) }
  let(:involvement_in_case) { nil }
  let(:requires_full_means_assessment?) { true }
  let(:requires_full_capital?) { true }

  before do
    allow(crime_application).to receive_messages(capital: record)

    allow(validator).to receive_messages(
      requires_full_means_assessment?: requires_full_means_assessment?,
      requires_full_capital?: requires_full_capital?
    )
  end

  describe '#applicable?' do
    subject(:applicable?) { validator.applicable? }

    context 'when full means assessment not required' do
      let(:requires_full_means_assessment?) { false }

      it { is_expected.to be(false) }
    end

    context 'when full means assessment required' do
      let(:requires_full_means_assessment?) { true }

      it { is_expected.to be(true) }
    end
  end

  describe '#complete?' do
    subject(:complete?) { validator.complete? }

    before do
      expect(validator).to receive(:validate)
      expect(errors).to receive(:empty?) { !errors_added? }
    end

    context 'when validate does not add errors' do
      let(:errors_added?) { false }

      it { is_expected.to be(true) }
    end

    context 'when validate adds errors' do
      let(:errors_added?) { true }

      it { is_expected.to be(false) }
    end
  end

  describe '#validate' do
    before { allow(record).to receive_messages(**attributes) }

    context 'when all validations pass' do
      let(:errors) { [] }

      let(:attributes) do
        {
          has_no_properties: 'no',
          properties: [instance_double(Property, complete?: true)],
          has_no_savings: 'no',
          savings: [instance_double(Saving, complete?: true)],
          has_no_investments: 'no',
          investments: [instance_double(Investment, complete?: true)],
          has_national_savings_certificates: 'no',
          has_premium_bonds: 'yes',
          premium_bonds_holder_number: '12345A',
          premium_bonds_total_value: 12_456,
          partner_has_premium_bonds: 'yes',
          partner_premium_bonds_holder_number: '7423F',
          partner_premium_bonds_total_value: 16_423,
          will_benefit_from_trust_fund: 'yes',
          trust_fund_amount_held: 100,
          has_frozen_income_or_assets: 'no',
          trust_fund_yearly_dividend: 1,
          partner_will_benefit_from_trust_fund: 'yes',
          partner_trust_fund_amount_held: 200,
          partner_trust_fund_yearly_dividend: 2,
          national_savings_certificates: [
            instance_double(NationalSavingsCertificate, complete?: true)
          ]

        }
      end

      before do
        allow(record).to receive(:usual_property_details_required?).and_return(false)
      end

      it 'does not add any errors' do
        subject.validate
      end
    end

    context 'when validation fails' do
      let(:involvement_in_case) { PartnerInvolvementType::NONE.to_s }

      let(:attributes) do
        {
          has_no_properties: nil,
          properties: [],
          has_no_savings: nil,
          savings: [],
          has_premium_bonds: nil,
          partner_has_premium_bonds: nil,
          has_no_investments: nil,
          investments: [],
          has_national_savings_certificates: nil,
          national_savings_certificates: [],
          will_benefit_from_trust_fund: nil,
          partner_will_benefit_from_trust_fund: nil,
          has_frozen_income_or_assets: nil
        }
      end

      before do
        allow(income).to receive(:has_frozen_income_or_assets).and_return(nil)
        allow(record).to receive(:usual_property_details_required?).and_return(true)
      end

      it 'adds errors for all failed validations' do # rubocop:disable RSpec/MultipleExpectations
        expect(errors).to receive(:add).with(:property_type, :blank)
        expect(errors).to receive(:add).with(:properties, :incomplete_records)
        expect(errors).to receive(:add).with(:saving_type, :blank)
        expect(errors).to receive(:add).with(:savings, :incomplete_records)
        expect(errors).to receive(:add).with(:premium_bonds, :blank)
        expect(errors).to receive(:add).with(:partner_premium_bonds, :blank)
        expect(errors).to receive(:add).with(:investment_type, :blank)
        expect(errors).to receive(:add).with(:has_national_savings_certificates, :blank)
        expect(errors).to receive(:add).with(:national_savings_certificates, :incomplete_records)
        expect(errors).to receive(:add).with(:investments, :incomplete_records)
        expect(errors).to receive(:add).with(:usual_property_details, :blank)
        expect(errors).to receive(:add).with(:trust_fund, :blank)
        expect(errors).to receive(:add).with(:partner_trust_fund, :blank)
        expect(errors).to receive(:add).with(:frozen_income_savings_assets_capital, :blank)
        expect(errors).to receive(:add).with(:base, :incomplete_records)

        subject.validate
      end

      context 'when full_capital not required' do
        let(:requires_full_capital?) { false }

        it 'does not add any errors' do
          expect(errors).to receive(:add).with(:trust_fund, :blank)
          expect(errors).to receive(:add).with(:partner_trust_fund, :blank)
          expect(errors).to receive(:add).with(:frozen_income_savings_assets_capital, :blank)
          expect(errors).to receive(:add).with(:base, :incomplete_records)

          subject.validate
        end
      end
    end
  end

  describe '#property_type_complete?' do
    context 'when record has no properties' do
      it 'returns true' do
        allow(record).to receive(:has_no_properties).and_return('yes')
        expect(subject.property_type_complete?).to be(true)
      end
    end

    context 'when record has properties' do
      before do
        allow(record).to receive(:has_no_properties).and_return(nil)
      end

      it 'returns true if properties are not empty' do
        allow(record).to receive(:properties).and_return([instance_double(Property)])
        expect(subject.property_type_complete?).to be(true)
      end

      it 'returns false if properties are empty' do
        allow(record).to receive(:properties).and_return([])
        expect(subject.property_type_complete?).to be(false)
      end
    end
  end

  describe '#properties_complete?' do
    context 'when record has no properties' do
      it 'returns true' do
        allow(record).to receive(:has_no_properties).and_return('yes')
        expect(subject.properties_complete?).to be(true)
      end
    end

    context 'when record has properties' do
      it 'returns true if all properties are complete' do
        allow(record).to receive_messages(has_no_properties: 'no', properties: [
                                            instance_double(Property, complete?: true)
                                          ])
        expect(subject.properties_complete?).to be(true)
      end

      it 'returns false if any property is incomplete' do
        allow(record).to receive_messages(has_no_properties: 'no', properties: [
                                            instance_double(Property, complete?: true),
                                            instance_double(Property, complete?: false)
                                          ])
        expect(subject.properties_complete?).to be(false)
      end
    end
  end

  describe '#investment_type_complete?' do
    context 'when record has no investments' do
      it 'returns true' do
        allow(record).to receive(:has_no_investments).and_return('yes')
        expect(subject.investment_type_complete?).to be(true)
      end
    end

    context 'when record has investments' do
      it 'returns true if investments are not empty' do
        allow(record).to receive_messages(has_no_investments: nil, investments: [instance_double(Investment)])
        expect(subject.investment_type_complete?).to be(true)
      end

      it 'returns false if investments are empty' do
        allow(record).to receive_messages(has_no_investments: nil, investments: [])
        expect(subject.investment_type_complete?).to be(false)
      end
    end
  end

  describe '#investments_complete?' do
    context 'when record has no investments' do
      it 'returns true' do
        allow(record).to receive(:has_no_investments).and_return('yes')
        expect(subject.investments_complete?).to be(true)
      end
    end

    context 'when record has investments' do
      it 'returns true if all investments are complete' do
        allow(record).to receive_messages(has_no_investments: nil, investments: [
                                            instance_double(Investment, complete?: true)
                                          ])
        expect(subject.investments_complete?).to be(true)
      end

      it 'returns false if any investment is incomplete' do
        allow(record).to receive_messages(has_no_investments: nil, investments: [
                                            instance_double(Investment, complete?: true),
                                            instance_double(Investment, complete?: false)
                                          ])
        expect(subject.investments_complete?).to be(false)
      end
    end
  end

  describe '#saving_type_complete?' do
    context 'when record has no savings' do
      it 'returns true' do
        allow(record).to receive(:has_no_savings).and_return('yes')
        expect(subject.saving_type_complete?).to be(true)
      end
    end

    context 'when record has savings' do
      it 'returns true if savings are not empty' do
        allow(record).to receive_messages(has_no_savings: nil, savings: [instance_double(Saving)])
        expect(subject.saving_type_complete?).to be(true)
      end

      it 'returns false if savings are empty' do
        allow(record).to receive_messages(has_no_savings: nil, savings: [])
        expect(subject.saving_type_complete?).to be(false)
      end
    end
  end

  describe '#savings_complete?' do
    context 'when record has no savings' do
      it 'returns true' do
        allow(record).to receive(:has_no_savings).and_return('yes')
        expect(subject.savings_complete?).to be(true)
      end
    end

    context 'when record has savings' do
      it 'returns true if all savings are complete' do
        allow(record).to receive_messages(has_no_savings: nil, savings: [
                                            instance_double(Saving, complete?: true)
                                          ])
        expect(subject.savings_complete?).to be(true)
      end

      it 'returns false if any saving is incomplete' do
        allow(record).to receive_messages(has_no_savings: nil, savings: [
                                            instance_double(Saving, complete?: true),
                                            instance_double(Saving, complete?: false)
                                          ])
        expect(subject.savings_complete?).to be(false)
      end
    end
  end

  describe '#premium_bonds_complete?' do
    it 'returns false when not answered' do
      allow(record).to receive(:has_premium_bonds).and_return('nil')
      expect(subject.premium_bonds_complete?).to be(false)
    end

    it 'returns true when answered no' do
      allow(record).to receive(:has_premium_bonds).and_return('no')
      expect(subject.premium_bonds_complete?).to be(true)
    end

    context 'when answered yes' do
      before do
        allow(record).to receive(:has_premium_bonds).and_return('yes')
      end

      context 'when trust fund details are provided' do
        before do
          allow(record).to receive_messages(premium_bonds_holder_number: '1235G', premium_bonds_total_value: 500)
        end

        it 'returns true' do
          expect(subject.premium_bonds_complete?).to be(true)
        end
      end

      context 'when trust fund details are missing' do
        before do
          allow(record).to receive_messages(premium_bonds_holder_number: nil, premium_bonds_total_value: nil)
        end

        it 'returns false' do
          expect(subject.premium_bonds_complete?).to be(false)
        end
      end
    end
  end

  describe '#partner_premium_bonds_complete?' do
    let(:involvement_in_case) { PartnerInvolvementType::NONE.to_s }

    it 'returns false when not answered' do
      allow(record).to receive(:partner_has_premium_bonds).and_return('nil')
      expect(subject.partner_premium_bonds_complete?).to be(false)
    end

    it 'returns true when answered no' do
      allow(record).to receive(:partner_has_premium_bonds).and_return('no')
      expect(subject.partner_premium_bonds_complete?).to be(true)
    end

    context 'when answered yes' do
      before do
        allow(record).to receive(:partner_has_premium_bonds).and_return('yes')
      end

      context 'when partner premium bonds details are provided' do
        before do
          allow(record).to receive_messages(partner_premium_bonds_holder_number: 10_000,
                                            partner_premium_bonds_total_value: 500)
        end

        it 'returns true' do
          expect(subject.partner_premium_bonds_complete?).to be(true)
        end
      end

      context 'when partner premium bonds details are missing' do
        before do
          allow(record).to receive_messages(partner_premium_bonds_holder_number: nil,
                                            partner_premium_bonds_total_value: nil)
        end

        it 'returns false' do
          expect(subject.partner_premium_bonds_complete?).to be(false)
        end
      end
    end
  end

  describe '#has_national_savings_certificates_complete?' do
    it 'returns true if record has national savings certificates' do
      allow(record).to receive(:has_national_savings_certificates).and_return('yes')
      expect(subject.has_national_savings_certificates_complete?).to be(true)
    end

    it 'returns true if record has no national savings certificates' do
      allow(record).to receive(:has_national_savings_certificates).and_return('no')
      expect(subject.has_national_savings_certificates_complete?).to be(true)
    end

    it 'returns false if question has not been answered' do
      allow(record).to receive(:has_national_savings_certificates).and_return(nil)
      expect(subject.has_national_savings_certificates_complete?).to be(false)
    end
  end

  describe '#national_savings_certificates_complete?' do
    context 'when record has no national savings certificates' do
      it 'returns true' do
        allow(record).to receive(:has_national_savings_certificates).and_return('no')
        expect(subject.national_savings_certificates_complete?).to be(true)
      end
    end

    context 'when record has national savings certificates' do
      it 'returns true if all certificates are complete' do
        allow(record).to receive_messages(has_national_savings_certificates: 'yes', national_savings_certificates: [
                                            instance_double(
                                              NationalSavingsCertificate, complete?: true
                                            )
                                          ])
        expect(subject.national_savings_certificates_complete?).to be(true)
      end

      it 'returns false if any certificate is incomplete' do
        allow(record).to receive_messages(has_national_savings_certificates: 'yes', national_savings_certificates: [
                                            instance_double(
                                              NationalSavingsCertificate, complete?: true
                                            ),
                                            instance_double(
                                              NationalSavingsCertificate, complete?: false
                                            )
                                          ])
        expect(subject.national_savings_certificates_complete?).to be(false)
      end
    end
  end

  describe '#trust_fund_complete?' do
    it 'returns false when not answered' do
      allow(record).to receive(:will_benefit_from_trust_fund).and_return('nil')
      expect(subject.trust_fund_complete?).to be(false)
    end

    it 'returns true when answered no' do
      allow(record).to receive(:will_benefit_from_trust_fund).and_return('no')
      expect(subject.trust_fund_complete?).to be(true)
    end

    context 'when answered yes' do
      before do
        allow(record).to receive(:will_benefit_from_trust_fund).and_return('yes')
      end

      context 'when trust fund details are provided' do
        before do
          allow(record).to receive_messages(trust_fund_amount_held: 10_000, trust_fund_yearly_dividend: 500)
        end

        it 'returns true' do
          expect(subject.trust_fund_complete?).to be(true)
        end
      end

      context 'when trust fund details are missing' do
        before do
          allow(record).to receive_messages(trust_fund_amount_held: nil, trust_fund_yearly_dividend: nil)
        end

        it 'returns false' do
          expect(subject.trust_fund_complete?).to be(false)
        end
      end
    end
  end

  describe '#partner_trust_fund_complete?' do
    let(:involvement_in_case) { PartnerInvolvementType::NONE.to_s }

    it 'returns false when not answered' do
      allow(record).to receive(:partner_will_benefit_from_trust_fund).and_return('nil')
      expect(subject.partner_trust_fund_complete?).to be(false)
    end

    it 'returns true when answered no' do
      allow(record).to receive(:partner_will_benefit_from_trust_fund).and_return('no')
      expect(subject.partner_trust_fund_complete?).to be(true)
    end

    context 'when answered yes' do
      before do
        allow(record).to receive(:partner_will_benefit_from_trust_fund).and_return('yes')
      end

      context 'when partner trust fund details are provided' do
        before do
          allow(record).to receive_messages(partner_trust_fund_amount_held: 10_000,
                                            partner_trust_fund_yearly_dividend: 500)
        end

        it 'returns true' do
          expect(subject.partner_trust_fund_complete?).to be(true)
        end
      end

      context 'when partner trust fund details are missing' do
        before do
          allow(record).to receive_messages(partner_trust_fund_amount_held: nil,
                                            partner_trust_fund_yearly_dividend: nil)
        end

        it 'returns false' do
          expect(subject.partner_trust_fund_complete?).to be(false)
        end
      end
    end
  end

  describe '#frozen_income_savings_assets_complete?' do
    it 'returns true when answered in capital' do
      allow(record).to receive(:has_frozen_income_or_assets).and_return('yes')
      expect(subject.frozen_income_savings_assets_complete?).to be(true)
    end

    context 'when not answered in captial' do
      before do
        allow(record).to receive(:has_frozen_income_or_assets).and_return(nil)
      end

      it 'returns true when answered in income' do
        allow(subject).to receive(:income) {
          instance_double(Income, has_frozen_income_or_assets: 'no')
        }

        expect(subject.frozen_income_savings_assets_complete?).to be(true)
      end

      it 'returns false when not answered in income' do
        allow(subject).to receive(:income) {
          instance_double(Income, has_frozen_income_or_assets: nil)
        }

        expect(subject.frozen_income_savings_assets_complete?).to be(false)
      end
    end
  end

  describe '#usual_property_details_complete?' do
    context 'when the usual property details are required' do
      before do
        allow(record).to receive(:usual_property_details_required?).and_return(true)
      end

      it { expect(subject.usual_property_details_complete?).to be(false) }
    end

    context 'when the usual property details are not required' do
      before do
        allow(record).to receive(:usual_property_details_required?).and_return(false)
      end

      it { expect(subject.usual_property_details_complete?).to be(true) }
    end
  end
end
