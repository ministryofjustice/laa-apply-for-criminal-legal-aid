require 'rails_helper'

RSpec.describe Income, type: :model do
  subject(:income) { described_class.new(crime_application:) }

  let(:crime_application) { CrimeApplication.new }

  it_behaves_like 'it has a means ownership scope'

  describe 'validations' do
    let(:answers_validator) { double('answers_validator') }

    before do
      allow(IncomeAssessment::AnswersValidator).to receive(:new).with(
        record: income
      ).and_return(answers_validator)
    end

    describe 'valid?(:submission)' do
      it 'validates answers' do
        expect(answers_validator).to receive(:validate)

        income.valid?(:submission)
      end
    end
  end

  describe '#complete?' do
    context 'when income is complete' do
      it 'returns true' do
        expect(income).to receive(:valid?).with(:submission).and_return(true)
        expect(income.complete?).to be true
      end
    end

    context 'when income is incomplete' do
      it 'returns false' do
        expect(income).to receive(:valid?).with(:submission).and_return(false)
        expect(income.complete?).to be false
      end
    end
  end

  describe '#employments' do
    subject(:employments) { income.employments }

    let(:employments_double) { double(:employments, where: ['results']) }

    before do
      allow(crime_application).to receive(:employments).and_return(employments_double)
    end

    context 'when not known if full means are necessary' do
      before do
        allow(MeansStatus).to receive(:full_means_required?).and_raise(
          Errors::CannotYetDetermineFullMeans
        )
      end

      it { is_expected.to eq [] }
    end

    context 'full means are not required' do
      before do
        allow(MeansStatus).to receive(:full_means_required?).and_return(false)
      end

      it { is_expected.to eq [] }
    end

    context 'when full means required' do
      before do
        income.employment_status = ['employed']
        income.partner_employment_status = ['employed']
        allow(MeansStatus).to receive(:full_means_required?).and_return(true)
      end

      context 'when partner is included in means' do
        before do
          allow(MeansStatus).to receive(:include_partner?).and_return(true)
        end

        it 'return applicant and partner employments' do
          expect(employments).to eq(['results'])
          expect(employments_double).to have_received(:where).with(
            ownership_type: %w[applicant partner]
          )
        end

        it 'does not return applicant if not employed' do
          income.employment_status = ['self_employed']

          expect(employments).to eq(['results'])
          expect(employments_double).to have_received(:where).with(
            ownership_type: ['partner']
          )
        end
      end

      context 'when partner is not included' do
        before do
          allow(MeansStatus).to receive(:include_partner?).and_return(false)
        end

        it 'return applicant and partner employments' do
          expect(employments).to eq(['results'])
          expect(employments_double).to have_received(:where).with(
            ownership_type: ['applicant']
          )
        end
      end
    end
  end

  describe '#partner_employment_income' do
    subject(:partner_employment_income) { income.partner_employment_income }

    let(:employment) { double(:employment) }
    let(:include_partner?) { true }
    let(:full_means?) { true }

    before do
      partner = instance_double(Partner)
      allow(crime_application).to receive(:partner).and_return(partner)
      allow(partner).to receive(:income_payments).and_return(double(:income, employment:))
      income.partner_employment_status = ['employed']
      allow(MeansStatus).to receive_messages(full_means_required?: full_means?, include_partner?: include_partner?)
    end

    context 'when not known if full means are necessary' do
      before do
        allow(MeansStatus).to receive(:full_means_required?).and_raise(
          Errors::CannotYetDetermineFullMeans
        )
      end

      it { is_expected.to be employment }
    end

    context 'when known that full means are necessary' do
      before do
        allow(MeansStatus).to receive(:full_means_required?).and_return(true)
      end

      it { is_expected.to be_nil }
    end

    context 'when known full means are not required' do
      let(:full_means?) { false }

      before do
        income.partner_employment_status = ['employed']
        allow(MeansStatus).to receive(:full_means_required?).and_return(false)
      end

      it { is_expected.to eq employment }

      context 'when parter is not included in means' do
        let(:include_partner?) { false }

        it { is_expected.to be_nil }
      end

      context 'when parter is not employed' do
        before do
          income.partner_employment_status = ['self_employed']
        end

        it { is_expected.to be_nil }
      end
    end
  end

  describe '#client_employment_income' do
    subject(:client_employment_income) { income.client_employment_income }

    let(:employment) { double(:employment) }
    let(:include_partner?) { true }
    let(:full_means?) { true }

    before do
      applicant = instance_double(Applicant)
      allow(crime_application).to receive(:applicant).and_return(applicant)
      allow(applicant).to receive(:income_payments).and_return(double(:income, employment:))
      income.employment_status = ['employed']
      allow(MeansStatus).to receive(:full_means_required?).and_return(full_means?)
    end

    context 'when not known if full means are necessary' do
      before do
        allow(MeansStatus).to receive(:full_means_required?).and_raise(
          Errors::CannotYetDetermineFullMeans
        )
      end

      it { is_expected.to be employment }
    end

    context 'when known that full means are necessary' do
      before do
        allow(MeansStatus).to receive(:full_means_required?).and_return(true)
      end

      it { is_expected.to be_nil }
    end

    context 'when known full means are not required' do
      let(:full_means?) { false }

      before do
        income.employment_status = ['employed']
        allow(MeansStatus).to receive(:full_means_required?).and_return(false)
      end

      it { is_expected.to eq employment }

      context 'when applicant is not employed' do
        before do
          income.employment_status = ['self_employed']
        end

        it { is_expected.to be_nil }
      end
    end
  end

  describe '#all_income_over_zero?' do
    subject(:all_income_over_zero) { income.all_income_over_zero? }

    context 'when there are any income payments or benefits' do
      before do
        allow(MeansStatus).to receive(:full_means_required?).and_return(false)
        partner = Partner.new

        crime_application = CrimeApplication.new(
          income:, partner_detail:, partner:
        )

        crime_application.income_payments = [
          IncomePayment.new(
            payment_type: 'maintenance',
            ownership_type: 'applicant',
            amount: 100,
            frequency: 'week',
          ),
          IncomePayment.new(
            payment_type: 'maintenance',
            ownership_type: 'partner',
            amount: 200,
            frequency: 'week',
          ),
        ]

        crime_application.income_benefits = [
          IncomeBenefit.new(
            payment_type: 'jsa',
            ownership_type: 'applicant',
            amount: 100,
            frequency: 'week',
          ),
          IncomeBenefit.new(
            payment_type: 'jsa',
            ownership_type: 'partner',
            amount: 200,
            frequency: 'week',
          ),
        ]

        income.has_no_income_payments = 'no'
        income.partner_has_no_income_payments = 'no'
        income.has_no_income_benefits = 'no'
        income.partner_has_no_income_benefits = 'no'

        crime_application.save!
      end

      let(:partner_detail) { PartnerDetail.new(involvement_in_case: 'none') }

      it { is_expected.to be true }

      it 'calculates the correct total' do
        expect(income.all_income_total).to eq 600
      end

      context 'when partner has contrary interest' do
        let(:partner_detail) { PartnerDetail.new(involvement_in_case: 'victim') }

        it 'only includes applicant payments' do
          expect(income.all_income_total).to eq 200
        end
      end
    end

    context 'when there is employment income' do
      let(:crime_application) {
        CrimeApplication.create!(
          employments: [
            Employment.new(amount: 12_000, ownership_type: 'applicant'),
            Employment.new(amount: 21_000, ownership_type: 'partner')
          ]
        )
      }

      before do
        income.employment_status = ['employed']
        allow(MeansStatus).to receive(:full_means_required?).and_return(true)
      end

      it { is_expected.to be true }

      it 'calculates the correct total' do
        expect(income.all_income_total).to eq 12_000
      end
    end

    context 'when there are no income payments or benefits' do
      before do
        allow(MeansStatus).to receive(:full_means_required?).and_return(false)
      end

      it { is_expected.to be false }

      it 'calculates the correct total' do
        expect(income.all_income_total).to eq 0
      end
    end
  end
end
