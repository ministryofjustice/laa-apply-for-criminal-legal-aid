require 'rails_helper'

RSpec.describe Steps::Case::OtherChargeInProgressForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) { { crime_application: crime_application, record: kase }.merge(attributes) }
  let(:crime_application) { CrimeApplication.create(case: kase) }
  let(:kase) { Case.new }
  let(:attributes) { { subject: Applicant.new } }

  before do
    allow(kase).to receive_messages(require_client_other_charge_in_progress?: true,
                                    require_partner_other_charge_in_progress?: true)
  end

  describe 'validations' do
    context 'when the subject is client' do
      let(:attributes) { { subject: Applicant.new } }

      it {
        expect(form).to validate_presence_of(
          :other_charge_in_progress,
          :inclusion,
          'Select yes if there is a criminal case or charge against the client in progress'
        )
      }
    end

    context 'when the subject is partner' do
      let(:attributes) { { subject: Partner.new } }

      it {
        expect(form).to validate_presence_of(
          :other_charge_in_progress,
          :inclusion,
          'Select yes if there is a criminal case or charge against the partner in progress'
        )
      }
    end
  end

  describe '#choices' do
    it 'returns the possible choices' do
      expect(
        form.choices
      ).to eq([YesNoAnswer::YES, YesNoAnswer::NO])
    end
  end

  describe '#save' do
    context 'when the subject is client' do
      let(:attributes) { { subject: Applicant.new, other_charge_in_progress: 'yes' } }

      it 'updates the `client_other_charge_in_progress` field' do
        expect { form.save }.to(
          change(
            kase, :client_other_charge_in_progress
          ).from(nil).to('yes').and(not_change(kase, :partner_other_charge_in_progress))
        )
      end

      it 'creates an `other_charge` record' do
        expect { form.save }.to change(OtherCharge, :count).from(0).to(1)
        other_charge = OtherCharge.first
        expect(other_charge.case).to eq(kase)
        expect(other_charge.ownership_type).to eq('applicant')
      end
    end

    context 'when the subject is partner' do
      let(:attributes) { { subject: Partner.new, other_charge_in_progress: 'yes' } }

      before { allow(kase).to receive(:require_partner_other_charge_in_progress?).and_return(true) }

      it 'updates the `partner_other_charge_in_progress` field' do
        expect { form.save }.to(
          change(
            kase, :partner_other_charge_in_progress
          ).from(nil).to('yes').and(not_change(kase, :client_other_charge_in_progress))
        )
      end

      it 'creates an `other_charge` record' do
        expect { form.save }.to change(OtherCharge, :count).from(0).to(1)
        other_charge = OtherCharge.first
        expect(other_charge.case).to eq(kase)
        expect(other_charge.ownership_type).to eq('partner')
      end
    end
  end
end
