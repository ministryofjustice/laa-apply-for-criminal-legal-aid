require 'rails_helper'

RSpec.describe CrimeApplication, type: :model do
  subject { described_class.new(attributes) }
  let(:attributes) { {} }

  describe 'custom contact details builders' do
    let(:person_double) { instance_double(Person) }

    context '#build_applicant_contact_details' do
      it 'calls the build method on the `applicant` association' do
        expect(subject).to receive(:applicant).and_return(person_double)
        expect(person_double).to receive(:build_contact_details)

        subject.build_applicant_contact_details
      end
    end

    context '#build_partner_contact_details' do
      it 'calls the build method on the `partner` association' do
        expect(subject).to receive(:partner).and_return(person_double)
        expect(person_double).to receive(:build_contact_details)

        subject.build_partner_contact_details
      end
    end
  end
end
