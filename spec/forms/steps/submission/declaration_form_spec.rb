require 'rails_helper'

RSpec.describe Steps::Submission::DeclarationForm do
  subject { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application:,
      declaration_signed:,
    }
  end

  let(:crime_application) { instance_double(CrimeApplication) }
  let(:declaration_signed) { '1' }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:declaration_signed) }

    context 'when checkbox is not ticked' do
      let(:declaration_signed) { '0' }

      it 'has a validation error on the field' do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:declaration_signed, :blank)).to be(true)
      end
    end
  end

  describe '#save' do
    it 'saves the record' do
      expect(crime_application).to receive(:update).with(
        'declaration_signed' => true
      ).and_return(true)

      expect(subject.save).to be(true)
    end
  end
end
