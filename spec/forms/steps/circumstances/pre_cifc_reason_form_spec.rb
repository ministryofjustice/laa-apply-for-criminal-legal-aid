require 'rails_helper'

RSpec.describe Steps::Circumstances::PreCifcReasonForm do
  subject { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application:,
      pre_cifc_reason:,
    }
  end

  let(:crime_application) { instance_double(CrimeApplication) }
  let(:pre_cifc_reason) { nil }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:pre_cifc_reason) }

    context 'with blank reason' do
      it 'has validation error' do
        ['', ' ', "\n\t"].each do |test_case|
          args = {
            crime_application: crime_application,
            pre_cifc_reason: test_case,
          }

          form_object = described_class.new(**args)

          expect(form_object).not_to be_valid
          expect(form_object.errors.of_kind?(:pre_cifc_reason, :blank)).to be(true)
        end
      end
    end
  end

  describe '#save' do
    let(:pre_cifc_reason) { 'Won the lottery' }

    it 'updates the record' do
      expect(crime_application).to receive(:update).with(
        {
          'pre_cifc_reason' => 'Won the lottery',
        }
      ).and_return(true)

      expect(subject.save).to be(true)
    end
  end
end
