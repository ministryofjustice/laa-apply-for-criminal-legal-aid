require 'rails_helper'

RSpec.describe Steps::Evidence::AdditionalInformationForm do
  subject(:form) { described_class.new(additional_information:, crime_application:) }

  let(:crime_application) { instance_double(CrimeApplication) }
  let(:additional_information) { 'More information about this application.' }
  let(:record_additional_information) { nil }

  before do
    allow(crime_application).to receive(:additional_information)
      .and_return(record_additional_information)
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:additional_information) }

    context 'when additional information is not needed' do
      before { form.add_additional_information = 'no' }

      it { is_expected.not_to validate_presence_of(:additional_information) }
    end
  end

  describe '#add_additional_information' do
    subject(:add_additional_information) { form.add_additional_information }

    context 'when no additional information stored' do
      it { is_expected.to be_nil }
    end

    context 'when additional information stored' do
      let(:record_additional_information) { 'Old information' }

      it { is_expected.to be YesNoAnswer::YES }
    end

    context 'when a new value is assigned' do
      before { form.add_additional_information = 'no' }

      it { is_expected.to eq YesNoAnswer::NO }
    end
  end

  describe '#save' do
    it 'stores the `additional_information`' do
      expect(crime_application).to receive(:update)
        .with(additional_information:).and_return(true)

      expect(form.save).to be true
    end

    context 'when additional information is not needed' do
      before { form.add_additional_information = 'no' }

      it 'clears the `additional_information`' do
        expect(crime_application).to receive(:update)
          .with(additional_information: nil).and_return(true)

        expect(form.save).to be true
      end
    end
  end

  describe '#choices' do
    subject(:choices) { form.choices }

    it { is_expected.to be YesNoAnswer.values }
  end
end
