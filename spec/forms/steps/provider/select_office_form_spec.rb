require 'rails_helper'

RSpec.describe Steps::Provider::SelectOfficeForm do
  subject { described_class.new(arguments) }

  let(:arguments) do
    {
      record: provider_record,
      office_code: office_code,
    }
  end

  let(:office_code) { nil }
  let(:provider_record) do
    instance_double(Provider, office_codes: %w[1A123B 2A555X])
  end

  describe '#choices' do
    it 'returns the possible choices' do
      expect(
        subject.choices
      ).to eq(%w[1A123B 2A555X])
    end
  end

  describe '#save' do
    context 'when `office_code` is not provided' do
      it 'returns false' do
        expect(subject.save).to be(false)
      end

      it 'has a validation error on the field' do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:office_code, :inclusion)).to be(true)
      end
    end

    context 'when `office_code` is not valid' do
      let(:is_current_office) { 'XYZ321' }

      it 'returns false' do
        expect(subject.save).to be(false)
      end

      it 'has a validation error on the field' do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:office_code, :inclusion)).to be(true)
      end
    end

    context 'when form is valid' do
      let(:office_code) { '1A123B' }

      it 'saves the record' do
        expect(provider_record).to receive(:update).with(
          { selected_office_code: office_code }
        ).and_return(true)

        expect(subject.save).to be(true)
      end
    end
  end
end
