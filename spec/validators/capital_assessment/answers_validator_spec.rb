require 'rails_helper'

RSpec.describe CapitalAssessment::AnswersValidator, type: :model do
  subject { described_class.new(record) }

  let(:record) { instance_double(Capital, errors:) }
  let(:errors) { double(:errors) }

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
          national_savings_certificates: [
            instance_double(NationalSavingsCertificate, complete?: true)
          ]

        }
      end

      it 'does not add any errors' do
        subject.validate
      end
    end

    context 'when validation fails' do
      let(:attributes) do
        {
          has_no_properties: nil,
          properties: [],
          has_no_savings: nil,
          savings: [],
          has_no_investments: nil,
          investments: [],
          has_national_savings_certificates: nil,
          national_savings_certificates: []
        }
      end

      it 'adds errors for all failed validations' do # rubocop:disable RSpec/MultipleExpectations
        expect(errors).to receive(:add).with(:property_type, :blank)
        expect(errors).to receive(:add).with(:properties, :incomplete_records)
        expect(errors).to receive(:add).with(:saving_type, :blank)
        expect(errors).to receive(:add).with(:savings, :incomplete_records)
        expect(errors).to receive(:add).with(:investment_type, :blank)
        expect(errors).to receive(:add).with(:has_national_savings_certificates, :blank)
        expect(errors).to receive(:add).with(:national_savings_certificates, :incomplete_records)
        expect(errors).to receive(:add).with(:investments, :incomplete_records)
        expect(errors).to receive(:add).with(:base, :incomplete_records)

        subject.validate
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
end
