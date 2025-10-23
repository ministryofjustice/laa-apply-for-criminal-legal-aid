require 'rails_helper'

RSpec.describe Steps::Capital::SavingTypeForm do
  subject(:form) { described_class.new(crime_application:) }

  let(:crime_application) { instance_double(CrimeApplication, capital:, savings:,) }
  let(:capital) { instance_double(Capital) }
  let(:savings) { class_double(Saving, where: existing_savings) }
  let(:existing_savings) { [] }

  describe '#choices' do
    it 'returns the possible choices' do
      expect(
        form.choices
      ).to eq([SavingType::BANK, SavingType::BUILDING_SOCIETY, SavingType::CASH_ISA,
               SavingType::NATIONAL_SAVINGS_OR_POST_OFFICE, SavingType::OTHER])
    end
  end

  describe '#validations' do
    before do
      allow(form).to receive(:include_partner_in_means_assessment?) { include_partner? }
      form.saving_type = nil
    end

    let(:include_partner?) { false }

    let(:error_message) do
      "Select which savings your client has inside or outside the UK, or select 'They do not have any of these savings'"
    end

    it { is_expected.to validate_presence_of(:saving_type, :blank, error_message) }

    context 'when partner is included in means assessment' do
      let(:include_partner?) { true }

      let(:error_message) do
        'Select which savings your client or their partner has inside or outside the UK, ' \
          "or select 'They do not have any of these savings'"
      end

      it { is_expected.to validate_presence_of(:saving_type, :blank, error_message) }
    end
  end

  describe '#saving_type' do
    subject(:saving_type) { form.saving_type }

    context 'when the question has not been answered' do
      before { allow(capital).to receive(:has_no_savings).and_return(nil) }

      it { is_expected.to be_nil }
    end

    context 'when capital#has_no_savings "yes"' do
      before { allow(capital).to receive(:has_no_savings).and_return('yes') }

      it { is_expected.to eq 'none' }
    end
  end

  describe '#save' do
    let(:saving_type) { SavingType.values.sample.to_s }
    let(:new_saving) { instance_double(Saving) }
    let(:existing_saving) { instance_double(Saving, complete?: complete?) }
    let(:complete?) { false }

    before do
      allow(savings).to receive(:create!).with(saving_type:).and_return new_saving
      allow(capital).to receive(:update).and_return true

      form.saving_type = saving_type
      form.save
    end

    context 'when client has no savings' do
      let(:saving_type) { 'none' }

      it 'does not set or create a saving' do
        expect(form.saving).to be_nil
        expect(savings).not_to have_received(:create!)
      end

      it 'updates the capita#has_no_savings to "yes"' do
        expect(capital).to have_received(:update).with(has_no_savings: 'yes')
      end
    end

    context 'when there are no existing savings records of the selected saving type' do
      it 'a new saving record of the saving type is created' do
        expect(form.saving).to be new_saving
        expect(savings).to have_received(:create!).with(saving_type:)
      end

      it 'sets capital#has_no_savings to nil' do
        expect(capital).to have_received(:update).with(has_no_savings: nil)
      end
    end

    context 'when a saving record of the selected saving type exists' do
      let(:existing_savings) { [existing_saving] }

      it 'is set as the saving record' do
        expect(form.saving).to be existing_saving
        expect(savings).not_to have_received(:create!)
      end

      context 'when the existing saving record is complete' do
        let(:complete?) { true }

        it 'a new saving record of the selected saving type is created' do
          expect(form.saving).to be new_saving
          expect(savings).to have_received(:create!).with(saving_type:)
        end
      end
    end
  end
end
