require 'rails_helper'

RSpec.describe Capital, type: :model do
  subject(:capital) { described_class.new }

  describe 'validations' do
    let(:answers_validator) { double('answers_validator') }
    let(:confirmation_validator) { double('confirmation_validator') }

    before do
      allow(CapitalAssessment::AnswersValidator).to receive(:new).with(record: capital)
                                                                 .and_return(answers_validator)
      allow(CapitalAssessment::ConfirmationValidator).to receive(:new).with(capital)
                                                                      .and_return(confirmation_validator)
    end

    describe 'valid?(:submission)' do
      it 'validates both answers and confirmation' do
        expect(answers_validator).to receive(:validate)
        expect(confirmation_validator).to receive(:validate)

        capital.valid?(:submission)
      end
    end

    describe 'valid?(:check_answers)' do
      it 'validates answers only' do
        expect(answers_validator).to receive(:validate)
        expect(confirmation_validator).not_to receive(:validate)

        capital.valid?(:check_answers)
      end
    end
  end

  describe '#complete?' do
    context 'when capital is complete' do
      it 'returns true' do
        expect(capital).to receive(:valid?).with(:submission).and_return(true)
        expect(capital.complete?).to be true
      end
    end

    context 'when capital is incomplete' do
      it 'returns false' do
        expect(capital).to receive(:valid?).with(:submission).and_return(false)
        expect(capital.complete?).to be false
      end
    end
  end

  describe '#investments' do
    subject(:capital_investments) { capital.investments }

    let(:capital) { described_class.new(has_no_investments:) }
    let(:crime_application) { CrimeApplication.new(capital:, investments:) }
    let(:has_no_investments) { nil }

    let(:investments) do
      [
        Investment.new(ownership_type: 'applicant', investment_type: 'bond'),
        Investment.new(ownership_type: 'partner', investment_type: 'pep')
      ]
    end

    before do
      crime_application.save!
      allow(MeansStatus).to receive_messages(
        include_partner?: include_partner, full_capital_required?: full_capital_required
      )
    end

    context 'when full capital required' do
      let(:include_partner) { true }
      let(:full_capital_required) { true }

      it { is_expected.to eq investments }
    end

    context 'when partner is excluded from means' do
      let(:include_partner) { false }
      let(:full_capital_required) { true }

      it { is_expected.to eq [investments.first] }
    end

    context 'when full capital is not required' do
      let(:include_partner) { true }
      let(:full_capital_required) { false }

      it { is_expected.to be_empty }
    end
  end

  describe '#properties' do
    subject(:capital_properties) { capital.properties }

    let(:capital) { described_class.new }
    let(:crime_application) { CrimeApplication.new(capital:, properties:) }
    let(:properties) { [Property.new(property_type: 'land')] }

    before do
      crime_application.save!
      allow(MeansStatus).to receive_messages(
        full_capital_required?: full_capital_required
      )
    end

    context 'when full capital required' do
      let(:include_partner) { true }
      let(:full_capital_required) { true }

      it { is_expected.to eq properties }
    end

    context 'when full capital is not required' do
      let(:include_partner) { true }
      let(:full_capital_required) { false }

      it { is_expected.to be_empty }
    end
  end

  describe '#national_savings_certificates' do
    subject(:capital_national_savings_certificates) { capital.national_savings_certificates }

    let(:capital) { described_class.new }
    let(:crime_application) { CrimeApplication.new(capital:, national_savings_certificates:) }

    let(:national_savings_certificates) do
      [
        NationalSavingsCertificate.new(ownership_type: 'applicant'),
        NationalSavingsCertificate.new(ownership_type: 'partner')
      ]
    end

    before do
      crime_application.save!
      allow(MeansStatus).to receive_messages(
        include_partner?: include_partner, full_capital_required?: full_capital_required
      )
    end

    context 'when full capital required' do
      let(:include_partner) { true }
      let(:full_capital_required) { true }

      it { is_expected.to eq national_savings_certificates }
    end

    context 'when partner is excluded from means' do
      let(:include_partner) { false }
      let(:full_capital_required) { true }

      it { is_expected.to eq [national_savings_certificates.first] }
    end

    context 'when full capital is not required' do
      let(:include_partner) { true }
      let(:full_capital_required) { false }

      it { is_expected.to be_empty }
    end
  end

  describe '#savings' do
    subject(:capital_savings) { capital.savings }

    let(:capital) { described_class.new(has_no_savings:) }
    let(:crime_application) { CrimeApplication.new(capital:, savings:) }
    let(:has_no_savings) { nil }

    let(:savings) do
      [
        Saving.new(ownership_type: 'applicant', saving_type: 'bank'),
        Saving.new(ownership_type: 'partner', saving_type: 'cash_isa')
      ]
    end

    before do
      crime_application.save!
      allow(MeansStatus).to receive_messages(
        include_partner?: include_partner, full_capital_required?: full_capital_required
      )
    end

    context 'when full capital required' do
      let(:include_partner) { true }
      let(:full_capital_required) { true }

      it { is_expected.to eq savings }
    end

    context 'when partner is excluded from means' do
      let(:include_partner) { false }
      let(:full_capital_required) { true }

      it { is_expected.to eq [savings.first] }
    end

    context 'when full capital is not required' do
      let(:include_partner) { true }
      let(:full_capital_required) { false }

      it { is_expected.to be_empty }
    end
  end

  describe 'has asset answers' do
    subject(:has_asset_answers) { capital.values_at(*attribute_names) }

    let(:attribute_names) do
      %i[
        has_national_savings_certificates
        has_no_savings
        has_no_investments
        has_premium_bonds
        partner_has_premium_bonds
      ]
    end

    before do
      attribute_names.each do |attr|
        capital.public_send(:"#{attr}=", 'yes')
      end
    end

    context 'full capital is required' do
      before do
        allow(MeansStatus).to receive(:full_capital_required?).and_return(true)
      end

      it 'returns the stored answers' do
        expect(has_asset_answers.uniq).to eq ['yes']
      end
    end

    context 'full capital is no longer required' do
      before do
        allow(MeansStatus).to receive(:full_capital_required?).and_return(false)
      end

      it 'returns the stored answers' do
        expect(has_asset_answers.uniq).to eq [nil]
      end
    end
  end

  describe '#usual_property_details_required?' do
    subject(:usual_property_details_required) { capital.usual_property_details_required? }

    let(:capital) { described_class.create(crime_application:) }
    let(:crime_application) { CrimeApplication.create(applicant:, properties:) }
    let(:applicant) { Applicant.create(residence_type:) }
    let(:residence_type) { nil }
    let(:properties) { [] }

    context 'when full capital is not required' do
      before do
        allow(MeansStatus).to receive(:full_capital_required?).and_return(false)
      end

      it { expect(usual_property_details_required).to be(false) }
    end

    context 'when full capital is required' do
      before do
        allow(MeansStatus).to receive(:full_capital_required?).and_return(true)
      end

      context 'and the client does not live in an owned proerty' do
        let(:residence_type) { ResidenceType::RENTED.to_s }

        it { expect(usual_property_details_required).to be(false) }
      end

      {
        ResidenceType::APPLICANT_OWNED.to_s => 'they own',
        ResidenceType::JOINT_OWNED.to_s => 'they and their partner both own'
      }.each do |type, desc|
        context "and the client lives in a property #{desc}" do
          let(:residence_type) { type }

          context 'and they have declared a property as their home address' do
            let(:properties) {
              [Property.create(property_type: PropertyType::RESIDENTIAL.to_s, is_home_address: YesNoAnswer::YES.to_s)]
            }

            it { expect(usual_property_details_required).to be(false) }
          end

          context 'and they have not declared a property as their home address' do
            let(:properties) { [] }

            it { expect(usual_property_details_required).to be(true) }
          end
        end
      end

      # rubocop:disable RSpec/NestedGroups
      context 'and the client lives in a property their partner owns' do
        let(:residence_type) { ResidenceType::PARTNER_OWNED.to_s }

        context 'and the partner should be included in the assessment' do
          before do
            allow(MeansStatus).to receive(:include_partner?).and_return(true)
          end

          context 'and they have declared a property as their home address' do
            let(:properties) {
              [Property.create(property_type: PropertyType::RESIDENTIAL.to_s, is_home_address: YesNoAnswer::YES.to_s)]
            }

            it { expect(usual_property_details_required).to be(false) }
          end

          context 'and they have not declared a property as their home address' do
            let(:properties) { [] }

            it { expect(usual_property_details_required).to be(true) }
          end
        end

        context 'and the partner should not be included in the assessment' do
          before do
            allow(MeansStatus).to receive(:include_partner?).and_return(false)
          end

          it { expect(usual_property_details_required).to be(false) }
        end
      end
      # rubocop:enable RSpec/NestedGroups
    end
  end

  describe '#has_no_properties' do
    subject(:has_no_properties) { capital.has_no_properties }

    let(:crime_application) { CrimeApplication.new(properties:) }
    let(:capital) { described_class.new(crime_application:) }
    let(:properties) { [] }

    before { capital.has_no_properties = 'yes' }

    context 'when a full capital assessment is not required' do
      before do
        allow(MeansStatus).to receive(:full_capital_required?).and_return(false)
      end

      it { expect(has_no_properties).to be_nil }
    end

    context 'when a full capital assessment is required' do
      before do
        allow(MeansStatus).to receive(:full_capital_required?).and_return(true)
      end

      context 'and properties have been added' do
        let(:properties) { [Property.new(property_type: 'land')] }

        it { expect(has_no_properties).to be_nil }
      end

      context 'and no properties have been added' do
        let(:properties) { [] }

        it { expect(has_no_properties).to eq('yes') }
      end
    end
  end

  it_behaves_like 'it has a means ownership scope'
end
