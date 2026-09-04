require 'rails_helper'

RSpec.describe Start::IsCifcForm do
  let(:crime_application) { instance_double(CrimeApplication) }

  describe '.build' do
    subject { described_class.build(crime_application, nil) }

    context 'with valid params' do
      it { is_expected.to be_a described_class }
    end
  end

  describe '#valid?' do
    subject { described_class.build(crime_application, is_cifc).valid? }

    context 'when is_cifc is `yes`' do
      let(:is_cifc) { 'yes' }

      it { is_expected.to be true }
    end

    context 'when is_cifc is `no`' do
      let(:is_cifc) { 'no' }

      it { is_expected.to be true }
    end

    context 'when is_cifc is `nil`' do
      let(:is_cifc) { nil }

      it { is_expected.to be false }
    end

    context 'with unknown is_cifc value' do
      it 'has errors' do
        form = described_class.build(crime_application, 'maybe')

        expect(form.valid?).to be false
        expect(form.errors.of_kind?(:is_cifc, :inclusion)).to be(true)

        expect(form.errors[:is_cifc]).to include(
          'Select whether you are making a new application or telling us about a change in financial circumstances'
        )
      end

      it 'localises the error message to the current locale' do
        form = described_class.build(crime_application, 'maybe')

        message = I18n.with_locale(:cy) do
          form.valid?
          form.errors[:is_cifc].first
        end

        expect(message).to eq(
          "Dewiswch a ydych chi'n gwneud cais newydd neu'n dweud wrthym am newid yn eich sefyllfa ariannol"
        )
      end
    end
  end

  describe '#save' do
    it 'returns true' do
      expect(described_class.new(crime_application:).save!).to be true
    end
  end
end
