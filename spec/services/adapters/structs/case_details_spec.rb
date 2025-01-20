require 'rails_helper'

RSpec.describe Adapters::Structs::CaseDetails do
  subject { application_struct.case }

  let(:application_struct) { build_struct_application }

  describe '#charges' do
    it 'returns a charges collection' do
      expect(subject.charges).to all(be_an(Charge))
    end
  end

  describe '#codefendants' do
    it 'returns a codefendants collection' do
      expect(subject.codefendants).to all(be_an(Codefendant))
    end
  end

  describe '#has_codefendants' do
    context 'when there are codefendants' do
      it 'returns `yes`' do
        expect(subject.has_codefendants).to eq(YesNoAnswer::YES)
      end
    end

    context 'when there are not codefendants' do
      before do
        allow(subject).to receive(:codefendants).and_return([])
      end

      it 'returns `no`' do
        expect(subject.has_codefendants).to eq(YesNoAnswer::NO)
      end
    end
  end

  describe '#client_other_charge' do
    it 'returns the charge with correct ownership_type' do
      expect(subject.client_other_charge.ownership_type).to eq(OwnershipType::APPLICANT.to_s)
    end
  end

  describe '#partner_other_charge' do
    it 'returns the charge with correct ownership_type' do
      expect(subject.partner_other_charge.ownership_type).to eq(OwnershipType::PARTNER.to_s)
    end
  end

  describe '#serializable_hash' do
    it 'returns a serializable hash, including relationships' do
      expect(
        subject.serializable_hash
      ).to match(
        a_hash_including(
          'charges' => all(be_an(Charge)),
          'codefendants' => all(be_an(Codefendant)),
          'has_codefendants' => YesNoAnswer::YES,
        )
      )
    end

    # rubocop:disable RSpec/ExampleLength
    it 'contains all required attributes' do
      expect(
        subject.serializable_hash.keys
      ).to match_array(
        %w[
          urn
          case_type
          appeal_lodged_date
          appeal_financial_circumstances_changed
          appeal_with_changes_details
          appeal_original_app_submitted
          appeal_reference_number
          appeal_maat_id
          appeal_usn
          has_case_concluded
          date_case_concluded
          is_preorder_work_claimed
          preorder_work_date
          preorder_work_details
          is_client_remanded
          date_client_remanded
          charges
          codefendants
          has_codefendants
          client_other_charge_in_progress
          partner_other_charge_in_progress
          client_other_charge
          partner_other_charge
          hearing_court_name
          hearing_date
          is_first_court_hearing
          first_court_hearing_name
        ]
      )
    end
    # rubocop:enable RSpec/ExampleLength

    context 'codefendants relationship' do
      it 'has the expected codefendants from the fixture' do
        codefendants = subject.serializable_hash['codefendants']
        expect(codefendants.size).to eq(1)

        codefendant = codefendants.first

        expect(codefendant.first_name).to eq('Zoe')
        expect(codefendant.last_name).to eq('Blogs')
        expect(codefendant.conflict_of_interest).to eq('yes')
      end
    end

    # rubocop:disable RSpec/MultipleExpectations
    context 'charges relationship' do
      it 'has the expected charges from the fixture' do
        charges = subject.serializable_hash['charges']
        expect(charges.size).to eq(2)

        charge1 = charges.first
        charge2 = charges.second

        expect(charge1.offence_name).to eq('Attempt robbery')
        expect(charge1.offence_dates.size).to eq(2)

        dates1 = charge1.offence_dates.first
        expect(dates1.date_from).to eq(Date.new(2020, 5, 11))
        expect(dates1.date_to).to eq(Date.new(2020, 5, 12))

        dates2 = charge1.offence_dates.second
        expect(dates2.date_from).to eq(Date.new(2020, 8, 11))
        expect(dates2.date_to).to be_nil

        expect(charge2.offence_name).to eq('Non-listed offence, manually entered')
        expect(charge2.offence_dates.size).to eq(1)

        dates1 = charge2.offence_dates.first
        expect(dates1.date_from).to eq(Date.new(2020, 9, 15))
        expect(dates1.date_to).to be_nil
      end
    end
    # rubocop:enable RSpec/MultipleExpectations
  end
end
