require 'rails_helper'

RSpec.describe Steps::Partner::InvolvementForm do
  subject(:form) { described_class.new(:involvement_in_case, crime_application:) }

  let(:crime_application) { instance_double(CrimeApplication) }
  let(:involvement_in_case) { [] }
  let(:record_involvement_in_case) { [] }

  before do
    allow(crime_application).to receive(:involvement_in_case)
      .and_return(record_additional_information)
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:additional_information) }

    context 'when additional information is not needed' do
      before { form.need_more_information = 'no' }

      it { is_expected.not_to validate_presence_of(:additional_information) }
    end
  end

  describe '#need_more_information' do
    subject(:need_more_information) { form.need_more_information }

    context 'when no additional information stored' do
      it { is_expected.to be_nil }
    end

    context 'when additional information stored' do
      let(:record_additional_information) { 'Old information' }

      it { is_expected.to be YesNoAnswer::YES }
    end

    context 'when a new value is assigned' do
      before { form.need_more_information = 'no' }

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
      before { form.need_more_information = 'no' }

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
