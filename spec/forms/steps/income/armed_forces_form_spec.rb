require 'rails_helper'

RSpec.describe Steps::Income::ArmedForcesForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) { { crime_application: crime_application, record: income }.merge(attributes) }
  let(:crime_application) { instance_double(CrimeApplication, income:) }
  let(:income) { Income.new }
  let(:attributes) { { subject: Applicant.new } }

  describe 'validations' do
    context 'when the subject is client' do
      let(:attributes) { { subject: Applicant.new } }

      it {
        expect(form).to validate_presence_of(:in_armed_forces, :inclusion,
                                             'Select yes if the client is in the armed forces')
      }
    end

    context 'when the subject is partner' do
      let(:attributes) { { subject: Partner.new } }

      it {
        expect(form).to validate_presence_of(:in_armed_forces, :inclusion,
                                             'Select yes if the partner is in the armed forces')
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
      let(:attributes) { { subject: Applicant.new, in_armed_forces: 'yes' } }

      before { allow(income).to receive(:require_client_in_armed_forces?).and_return(true) }

      it 'updates the `client_in_armed_forces` field' do
        expect { form.save }.to change(income, :client_in_armed_forces).from(nil).to('yes')
                                                                       .and not_change(income,
                                                                                       :partner_in_armed_forces)
      end
    end

    context 'when the subject is partner' do
      let(:attributes) { { subject: Partner.new, in_armed_forces: 'yes' } }

      before { allow(income).to receive(:require_partner_in_armed_forces?).and_return(true) }

      it 'updates the `partner_in_armed_forces` field' do
        expect { form.save }.to change(income, :partner_in_armed_forces).from(nil).to('yes')
                                                                        .and not_change(income,
                                                                                        :client_in_armed_forces)
      end
    end
  end
end
