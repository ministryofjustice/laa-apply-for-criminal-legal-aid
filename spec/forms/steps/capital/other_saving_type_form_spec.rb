require 'rails_helper'

RSpec.describe Steps::Capital::OtherSavingTypeForm do
  subject(:form) { described_class.new(crime_application:) }

  let(:crime_application) { instance_double(CrimeApplication, savings:) }
  let(:savings) { double }
  let(:saving_type) { SavingType.values.sample.to_s }
  let(:new_saving) { instance_double(Saving) }

  describe '#choices' do
    it 'returns saving types' do
      expect(form.choices).to match SavingType.values
    end
  end

  describe '#save' do
    before do
      allow(form).to receive(:include_partner_in_means_assessment?).and_return(true)
      allow(savings).to receive(:create!).with(saving_type:).and_return new_saving

      form.saving_type = saving_type
      form.save
    end

    context 'when a saving of the type exists' do
      it 'a new saving of the saving type is created' do
        expect(form.saving).to be new_saving
        expect(savings).to have_received(:create!).with(saving_type:)
      end
    end

    context 'when saving type is an empty string' do
      let(:saving_type) { '' }

      it 'does not create a saving' do
        expect(savings).not_to have_received(:create!).with(saving_type:)
      end
    end
  end

  describe '#validations' do
    before do
      allow(form).to receive(:include_partner_in_means_assessment?) { include_partner? }
      form.saving_type = nil
    end

    let(:include_partner?) { false }

    let(:error_message) do
      'Select which other savings your client has inside or outside the UK'
    end

    it { is_expected.to validate_presence_of(:saving_type, :blank, error_message) }

    context 'when partner is included in means assessment' do
      let(:include_partner?) { true }

      let(:error_message) do
        'Select which other savings your client or their partner has inside or outside the UK'
      end

      it { is_expected.to validate_presence_of(:saving_type, :blank, error_message) }
    end
  end
end
