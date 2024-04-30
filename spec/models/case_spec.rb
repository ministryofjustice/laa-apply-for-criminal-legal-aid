require 'rails_helper'

RSpec.describe Case, type: :model do
  subject(:instance) { described_class.new(attributes) }

  let(:attributes) { {} }

  let(:case_attributes) do
    {
      crime_application: CrimeApplication.new,
      hearing_court_name: 'court name',
      hearing_date: Time.zone.today,
      is_first_court_hearing: nil,
      first_court_hearing_name: nil,
      has_case_concluded: nil,
      date_case_concluded: nil,
      is_client_remanded: nil,
      date_client_remanded: nil,
      is_preorder_work_claimed: nil,
      preorder_work_date: nil,
      preorder_work_details: nil
    }
  end

  describe '#hearing_court' do
    let(:attributes) { { hearing_court_name: court_name } }

    context 'for a known court' do
      let(:court_name) { 'Croydon Crown Court' }

      it { expect(subject.hearing_court).not_to be_nil }
      it { expect(subject.hearing_court.name).to eq(court_name) }
    end

    context 'for an unknown court' do
      let(:court_name) { 'Foobar Court' }

      it { expect(subject.hearing_court).to be_nil }
    end

    context 'for a blank court' do
      let(:court_name) { '' }

      it { expect(subject.hearing_court).to be_nil }
    end
  end

  describe '`charges` relationship' do
    subject(:charges) do
      described_class.create(
        crime_application:
      ).charges
    end

    let(:crime_application) { CrimeApplication.create }

    it 'initialises a blank `offence_date` when building charges' do
      expect(
        charges.build.offence_dates
      ).to contain_exactly(kind_of(OffenceDate))
    end

    it 'initialises a blank `offence_date` when adding charges' do
      expect do
        charges << Charge.new
      end.to change(OffenceDate, :count).by(1)
    end

    it 'initialises a blank `offence_date` when creating charges' do
      expect do
        charges.create
      end.to change(OffenceDate, :count).by(1)
    end

    it 'has an association extension to return only complete charges' do
      charges << Charge.new
      expect(charges.complete).to be_empty
    end
  end

  # rubocop:disable RSpec/PredicateMatcher
  describe 'complete?' do
    context 'case hearing attributes' do
      let(:attributes) { case_attributes }

      context 'when valid attributes' do
        it { expect(subject.complete?).to be_truthy }
      end

      context 'when invalid attributes' do
        let(:attributes) do
          case_attributes.merge(
            hearing_court_name: 'court name',
            hearing_date: nil
          )
        end

        it { expect(subject.complete?).to be_falsey }
      end
    end

    context 'case concluded attributes' do
      context 'when valid attributes' do
        let(:attributes) do
          case_attributes.merge(
            has_case_concluded: 'yes',
            date_case_concluded: Time.zone.today
          )
        end

        it { expect(subject.complete?).to be_truthy }
      end

      context 'when invalid attributes' do
        let(:attributes) do
          case_attributes.merge(
            has_case_concluded: 'yes',
            date_case_concluded: nil
          )
        end

        it { expect(subject.complete?).to be_falsey }
      end
    end

    context 'case pre-order work attributes' do
      context 'when valid attributes' do
        let(:attributes) do
          case_attributes.merge(
            is_preorder_work_claimed: 'yes',
            preorder_work_date: Time.zone.today,
            preorder_work_details: 'details'
          )
        end

        it { expect(subject.complete?).to be_truthy }
      end

      context 'when invalid attributes' do
        let(:attributes) do
          case_attributes.merge(
            is_preorder_work_claimed: 'yes',
            preorder_work_date: nil,
            preorder_work_details: 'details'
          )
        end

        it { expect(subject.complete?).to be_falsey }
      end
    end

    context 'case client remanded attributes' do
      context 'valid attributes' do
        let(:attributes) do
          case_attributes.merge(
            is_client_remanded: 'yes',
            date_client_remanded: Time.zone.today
          )
        end

        it { expect(subject.complete?).to be_truthy }
      end

      context 'when invalid attributes' do
        let(:attributes) do
          case_attributes.merge(
            is_client_remanded: 'yes',
            date_client_remanded: nil
          )
        end

        it { expect(subject.complete?).to be_falsey }
      end
    end
  end
  # rubocop:enable RSpec/PredicateMatcher

  describe 'valid?(:submission)' do
    subject(:valid?) { instance.valid?(:submission) }

    context 'when not complete?' do
      it { is_expected.to be false }

      it 'has errors on base' do
        valid?
        expect(instance.errors.of_kind?(:base, :incomplete_records)).to be(true)
      end
    end

    context 'when complete?' do
      let(:attributes) { case_attributes }

      it { is_expected.to be true }
    end
  end
end
