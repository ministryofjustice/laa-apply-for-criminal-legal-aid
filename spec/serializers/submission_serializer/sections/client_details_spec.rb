require 'rails_helper'

RSpec.describe SubmissionSerializer::Sections::ClientDetails do
  subject { described_class.new(crime_application) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      applicant: applicant,
      partner: partner,
      partner_detail: partner_detail,
      non_means_tested?: non_means_tested
    )
  end

  let(:applicant) do
    instance_double(
      Applicant,
      id: '1234',
      first_name: 'Max',
      last_name: 'Mustermann',
      other_names: '',
      date_of_birth: date_of_birth,
      has_nino: 'yes',
      nino: 'AB123456A',
      has_arc: nil,
      arc: nil,
      benefit_type: 'universal_credit',
      last_jsa_appointment_date: nil,
      home_address: home_address,
      correspondence_address: correspondence_address,
      telephone_number: '123456789',
      correspondence_address_type: 'home_address',
      preferred_correspondence_language: nil,
      residence_type: 'rented',
      relationship_to_owner_of_usual_home_address: nil,
      confirm_dwp_result: 'no',
      benefit_check_result: false,
      dwp_response: nil,
      will_enter_nino: nil,
      has_benefit_evidence: 'yes',
      confirm_details: 'yes',
    )
  end

  let(:date_of_birth) { DateTime.new(1950, 1, 1) }
  let(:non_means_tested) { false }

  let(:home_address) do
    instance_double(
      HomeAddress,
      address_line_one: 'Test',
      address_line_two: 'Home',
      postcode: 'A11 1XX',
      city: 'City',
      country: 'Country',
      lookup_id: 1,
    )
  end

  let(:correspondence_address) do
    # Incomplete address, on purpose
    CorrespondenceAddress.new(postcode: 'A11 1XX')
  end

  let(:applicant_without_partner) do
    {
      client_details: {
        applicant: {
          first_name: 'Max',
          last_name: 'Mustermann',
          other_names: '',
          date_of_birth: date_of_birth,
          has_nino: 'yes',
          nino: 'AB123456A',
          has_arc: nil,
          arc: nil,
          benefit_type: 'universal_credit',
          last_jsa_appointment_date: nil,
          home_address: {
            address_line_one: 'Test',
            address_line_two: 'Home',
            city: 'City',
            country: 'Country',
            postcode: 'A11 1XX',
            lookup_id: 1,
          },
          correspondence_address: nil,
          telephone_number: '123456789',
          correspondence_address_type: 'home_address',
          preferred_correspondence_language: nil,
          residence_type: 'rented',
          relationship_to_owner_of_usual_home_address: nil,
          benefit_check_result: false,
          benefit_check_status: 'undetermined',
          will_enter_nino: nil,
          has_benefit_evidence: 'yes',
          confirm_details: 'yes',
          confirm_dwp_result: 'no',
          has_partner: has_partner,
          relationship_to_partner: relationship_to_partner,
          relationship_status: relationship_status,
          separation_date: nil,
          dwp_response: nil,
        },
        partner: nil,
      }
    }
  end

  let(:non_means_tested_client) do
    {
      client_details: {
        applicant: {
          first_name: 'Max',
          last_name: 'Mustermann',
          other_names: '',
          date_of_birth: date_of_birth,
          has_nino: 'yes',
          nino: 'AB123456A',
          has_arc: nil,
          arc: nil,
          home_address: {
            address_line_one: 'Test',
            address_line_two: 'Home',
            city: 'City',
            country: 'Country',
            postcode: 'A11 1XX',
            lookup_id: 1,
          },
          correspondence_address: nil,
          telephone_number: '123456789',
          correspondence_address_type: 'home_address',
          preferred_correspondence_language: nil,
          residence_type: 'rented',
          relationship_to_owner_of_usual_home_address: nil,
        }
      }
    }
  end

  # rubocop:disable RSpec/MultipleMemoizedHelpers
  describe '#generate' do
    context 'without partner' do
      let(:has_partner) { 'no' }
      let(:relationship_to_partner) { nil }
      let(:relationship_status) { 'divorced' }
      let(:partner) { nil }

      let(:partner_detail) do
        instance_double(
          PartnerDetail,
          relationship_to_partner: relationship_to_partner,
          relationship_status: relationship_status,
          separation_date: nil,
          involvement_in_case: nil,
          has_partner: has_partner,
        )
      end

      it { expect(subject.generate).to eq(applicant_without_partner.as_json) }
    end

    context 'with partner without conflict of interest' do
      before do
        allow(MeansStatus).to receive(:include_partner?).and_return(true)
        allow(partner).to receive_messages(
          home_address: nil,
        )
      end

      let(:has_partner) { 'yes' }
      let(:relationship_to_partner) { 'married_or_partnership' }
      let(:relationship_status) { nil }

      let(:partner) do
        instance_double(
          Partner,
          id: '123',
          first_name: 'Fred',
          last_name: 'Flint',
          other_names: nil,
          date_of_birth: nil,
          has_nino: 'no',
          nino: nil,
          has_arc: nil,
          arc: nil,
          benefit_type: nil,
          last_jsa_appointment_date: nil,
          benefit_check_result: false,
          will_enter_nino: nil,
          has_benefit_evidence: nil,
          confirm_details: nil,
          confirm_dwp_result: nil,
          dwp_response: nil,
        )
      end

      let(:partner_detail) do
        instance_double(
          PartnerDetail,
          involvement_in_case: 'victim',
          conflict_of_interest: nil,
          has_same_address_as_client: nil,
          relationship_to_partner: relationship_to_partner,
          relationship_status: relationship_status,
          separation_date: nil,
          has_partner: has_partner,
        )
      end

      let(:applicant_with_partner) do
        partner_attributes = {
          first_name: 'Fred',
          last_name: 'Flint',
          other_names: nil,
          date_of_birth: nil,
          has_nino: 'no',
          nino: nil,
          has_arc: nil,
          arc: nil,
          involvement_in_case: 'victim',
          conflict_of_interest: nil,
          has_same_address_as_client: nil,
          home_address: nil,
          benefit_type: nil,
          last_jsa_appointment_date: nil,
          benefit_check_result: false,
          benefit_check_status: 'no_check_required',
          will_enter_nino: nil,
          has_benefit_evidence: nil,
          confirm_details: nil,
          confirm_dwp_result: nil,
          dwp_response: nil,
          is_included_in_means_assessment: true
        }

        applicant_without_partner.deep_merge(client_details: { partner: partner_attributes })
      end

      it { expect(subject.generate).to eq(applicant_with_partner.as_json) }

      context 'when non-means tested application' do
        let(:non_means_tested) { true }

        it { expect(subject.generate).not_to eq(applicant_with_partner.as_json) }
        it { expect(subject.generate).to eq(non_means_tested_client.as_json) }
      end
    end

    context 'with partner with conflict of interest' do
      before do
        allow(MeansStatus).to receive(:include_partner?).and_return(false)
      end

      let(:has_partner) { 'yes' }
      let(:relationship_to_partner) { 'married_or_partnership' }
      let(:relationship_status) { nil }

      let(:partner) do
        instance_double(
          Partner,
          id: '123',
          first_name: 'Fred',
          last_name: 'Flint',
          other_names: nil,
          date_of_birth: nil,
          has_nino: 'no',
          nino: nil,
          has_arc: nil,
          arc: nil,
          benefit_type: nil,
          last_jsa_appointment_date: nil,
          benefit_check_result: false,
          will_enter_nino: nil,
          has_benefit_evidence: nil,
          confirm_details: nil,
          confirm_dwp_result: nil,
          dwp_response: nil,
        )
      end

      let(:partner_detail) do
        instance_double(
          PartnerDetail,
          involvement_in_case: 'victim',
          conflict_of_interest: nil,
          has_same_address_as_client: nil,
          relationship_to_partner: relationship_to_partner,
          relationship_status: relationship_status,
          separation_date: nil,
          has_partner: has_partner,
        )
      end

      let(:applicant_with_partner) do
        partner_attributes = {
          first_name: 'Fred',
          last_name: 'Flint',
          other_names: nil,
          date_of_birth: nil,
          has_nino: 'no',
          nino: nil,
          has_arc: nil,
          arc: nil,
          involvement_in_case: 'victim',
          conflict_of_interest: nil,
          is_included_in_means_assessment: false
        }

        applicant_without_partner.deep_merge(client_details: { partner: partner_attributes })
      end

      it { expect(subject.generate).to eq(applicant_with_partner.as_json) }
    end
  end
  # rubocop:enable RSpec/MultipleMemoizedHelpers
end
