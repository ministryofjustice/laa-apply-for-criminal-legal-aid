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

  describe '#applicant_self_assessment_tax_bill' do
    subject(:applicant_self_assessment_tax_bill) { income.applicant_self_assessment_tax_bill }

    before do
      income.applicant_self_assessment_tax_bill = 'yes'
    end

    context 'when not known if full means are necessary' do
      before do
        allow(MeansStatus).to receive(:full_means_required?).and_raise(
          Errors::CannotYetDetermineFullMeans
        )
      end

      it { is_expected.to be_nil }
    end

    context 'when full means required and client is employed' do
      before do
        income.employment_status = ['employed']
        allow(MeansStatus).to receive(:full_means_required?).and_return(true)
      end

      it { is_expected.to eq 'yes' }
    end

    context 'when full means required and client is self-employed' do
      before do
        income.employment_status = ['self_employed']
        allow(MeansStatus).to receive(:full_means_required?).and_return(true)
      end

      it { is_expected.to eq 'yes' }
    end

    context 'when full means required and client is not employed' do
      before do
        income.employment_status = ['not_working']
        allow(MeansStatus).to receive(:full_means_required?).and_return(true)
      end

      it { is_expected.to be_nil }
    end
  end

  describe '#partner_self_assessment_tax_bill' do
    subject(:partner_self_assessment_tax_bill) { income.partner_self_assessment_tax_bill }

    before do
      allow(MeansStatus).to receive(:include_partner?).and_return(true)
      income.partner_self_assessment_tax_bill = 'yes'
    end

    context 'when not known if full means are necessary' do
      before do
        allow(MeansStatus).to receive(:full_means_required?).and_raise(
          Errors::CannotYetDetermineFullMeans
        )
      end

      it { is_expected.to be_nil }
    end

    context 'when full means required and partner is employed' do
      before do
        income.partner_employment_status = ['employed']
        allow(MeansStatus).to receive(:full_means_required?).and_return(true)
      end

      it { is_expected.to eq 'yes' }
    end

    context 'when full means required and partner is self employed' do
      before do
        income.partner_employment_status = ['self_employed']
        allow(MeansStatus).to receive(:full_means_required?).and_return(true)
      end

      it { is_expected.to eq 'yes' }
    end

    context 'when full means required and partner is employed and no longer mean assessed' do
      before do
        income.partner_employment_status = ['employed']
        allow(MeansStatus).to receive_messages(full_means_required?: true, include_partner?: false)
      end

      it { is_expected.to be_nil }
    end

    context 'when full means required and client is not employed' do
      before do
        income.partner_employment_status = ['not_working']
        allow(MeansStatus).to receive(:full_means_required?).and_return(true)
      end

      it { is_expected.to be_nil }
    end
  end

  describe '#applicant_other_work_benefit_received' do
    subject(:applicant_other_work_benefit_received) { income.applicant_other_work_benefit_received }

    before do
      income.applicant_other_work_benefit_received = 'yes'
    end

    context 'when not known if full means are necessary' do
      before do
        allow(MeansStatus).to receive(:full_means_required?).and_raise(
          Errors::CannotYetDetermineFullMeans
        )
      end

      it { is_expected.to be_nil }
    end

    context 'when full means required and client is employed' do
      before do
        income.employment_status = ['employed']
        allow(MeansStatus).to receive(:full_means_required?).and_return(true)
      end

      it { is_expected.to eq 'yes' }
    end

    context 'when full means required and client is self-employed' do
      before do
        income.employment_status = ['self_employed']
        allow(MeansStatus).to receive(:full_means_required?).and_return(true)
      end

      it { is_expected.to eq 'yes' }
    end

    context 'when full means required and client is not employed' do
      before do
        income.employment_status = ['not_working']
        allow(MeansStatus).to receive(:full_means_required?).and_return(true)
      end

      it { is_expected.to be_nil }
    end
  end

  describe '#partner_other_work_benefit_received' do
    subject(:partner_other_work_benefit_received) { income.partner_other_work_benefit_received }

    before do
      allow(MeansStatus).to receive(:include_partner?).and_return(true)
      income.partner_other_work_benefit_received = 'yes'
    end

    context 'when not known if full means are necessary' do
      before do
        allow(MeansStatus).to receive(:full_means_required?).and_raise(
          Errors::CannotYetDetermineFullMeans
        )
      end

      it { is_expected.to be_nil }
    end

    context 'when full means required and partner is employed' do
      before do
        income.partner_employment_status = ['employed']
        allow(MeansStatus).to receive(:full_means_required?).and_return(true)
      end

      it { is_expected.to eq 'yes' }
    end

    context 'when full means required and partner is self-employed' do
      before do
        income.partner_employment_status = ['self_employed']
        allow(MeansStatus).to receive(:full_means_required?).and_return(true)
      end

      it { is_expected.to eq 'yes' }
    end

    context 'when full means required and partner is employed and no longer mean assessed' do
      before do
        income.partner_employment_status = ['employed']
        allow(MeansStatus).to receive_messages(full_means_required?: true, include_partner?: false)
      end

      it { is_expected.to be_nil }
    end

    context 'when full means required and client is not employed' do
      before do
        income.partner_employment_status = ['not_working']
        allow(MeansStatus).to receive(:full_means_required?).and_return(true)
      end

      it { is_expected.to be_nil }
    end
  end

  describe '#client_employment_income' do
    subject(:client_employment_income) { income.client_employment_income }

    let(:expected) {
      instance_double(
        IncomePayment,
        ownership_type: OwnershipType::APPLICANT.to_s,
        payment_type: IncomePaymentType::EMPLOYMENT.to_s
      )
    }

    before do
      allow(income).to receive(:income_payments).and_return(
        [
          expected,
          instance_double(IncomePayment, ownership_type: OwnershipType::PARTNER.to_s,
payment_type: IncomePaymentType::EMPLOYMENT.to_s),
          instance_double(IncomePayment, ownership_type: OwnershipType::APPLICANT.to_s,
payment_type: IncomePaymentType::WORK_BENEFITS.to_s)
        ]
      )
    end

    it { is_expected.to eq(expected) }
  end

  describe '#client_work_benefits' do
    subject(:client_work_benefits) { income.client_work_benefits }

    let(:expected) {
      instance_double(
        IncomePayment,
        ownership_type: OwnershipType::APPLICANT.to_s,
        payment_type: IncomePaymentType::WORK_BENEFITS.to_s
      )
    }

    before do
      allow(income).to receive(:income_payments).and_return(
        [
          expected,
          instance_double(IncomePayment, ownership_type: OwnershipType::APPLICANT.to_s,
payment_type: IncomePaymentType::EMPLOYMENT.to_s),
          instance_double(IncomePayment, ownership_type: OwnershipType::PARTNER.to_s,
payment_type: IncomePaymentType::WORK_BENEFITS.to_s)
        ]
      )
    end

    it { is_expected.to eq(expected) }
  end

  describe '#partenr_work_benefits' do
    subject(:partenr_work_benefits) { income.partner_work_benefits }

    let(:expected) {
      instance_double(
        IncomePayment,
        ownership_type: OwnershipType::PARTNER.to_s,
        payment_type: IncomePaymentType::WORK_BENEFITS.to_s
      )
    }

    before do
      allow(income).to receive(:income_payments).and_return(
        [
          expected,
          instance_double(IncomePayment, ownership_type: OwnershipType::APPLICANT.to_s,
payment_type: IncomePaymentType::EMPLOYMENT.to_s),
          instance_double(IncomePayment, ownership_type: OwnershipType::APPLICANT.to_s,
payment_type: IncomePaymentType::WORK_BENEFITS.to_s)
        ]
      )
    end

    it { is_expected.to eq(expected) }
  end

  describe '#partner_employment_income' do
    subject(:partner_employment_income) { income.partner_employment_income }

    let(:expected) {
      instance_double(
        IncomePayment,
        ownership_type: OwnershipType::PARTNER.to_s,
        payment_type: IncomePaymentType::EMPLOYMENT.to_s
      )
    }

    before do
      allow(income).to receive(:income_payments).and_return(
        [
          expected,
          instance_double(IncomePayment, ownership_type: OwnershipType::APPLICANT.to_s,
payment_type: IncomePaymentType::EMPLOYMENT.to_s),
          instance_double(IncomePayment, ownership_type: OwnershipType::APPLICANT.to_s,
payment_type: IncomePaymentType::WORK_BENEFITS.to_s)
        ]
      )
    end

    it { is_expected.to eq(expected) }
  end

  describe '#all_income_over_zero?' do
    subject(:all_income_over_zero) { income.all_income_over_zero? }

    context 'when there are any income payments or benefits' do
      before do
        allow(MeansStatus).to receive(:full_means_required?).and_return(false)
        partner = Partner.new
        applicant = Applicant.new

        crime_application = CrimeApplication.new(
          income:, partner_detail:, partner:, applicant:
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
        income.employment_status = ['employed']
        income.partner_employment_status = ['employed']

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

    describe '#income_paymnents' do
      subject(:income_payments) { income.income_payments }

      let(:crime_application) { CrimeApplication.create!(applicant: Applicant.new, partner: Partner.new) }
      let(:owners) { income_payments.pluck(:ownership_type).uniq }
      let(:payment_types) { income_payments.pluck(:payment_type).uniq }

      before do
        base = { type: 'IncomePayment', crime_application_id: crime_application.id, amount: 1, frequency: 'week' }

        # rubocop:disable Rails/SkipsModelValidations
        IncomePayment.insert_all(
          [
            base.merge(ownership_type: 'partner', payment_type: 'employment'),
            base.merge(ownership_type: 'applicant', payment_type: 'employment'),
            base.merge(ownership_type: 'partner', payment_type: 'work_benefits'),
            base.merge(ownership_type: 'applicant', payment_type: 'work_benefits'),
            base.merge(ownership_type: 'partner', payment_type: 'maintenance'),
            base.merge(ownership_type: 'applicant', payment_type: 'maintenance')
          ]
        )

        # rubocop:enable Rails/SkipsModelValidations
      end

      context 'when neither are employed' do
        before do
          allow(MeansStatus).to receive_messages(include_partner?: true, full_means_required?: false)
        end

        it 'returns non-employment payment types for both client and partner' do
          expect(owners).to contain_exactly 'partner', 'applicant'
          expect(payment_types).to contain_exactly 'maintenance'
        end
      end

      context 'when both are employed and full means is not required' do
        before do
          allow(MeansStatus).to receive_messages(include_partner?: true, full_means_required?: false)
          income.employment_status = ['employed']
          income.partner_employment_status = ['employed']
        end

        it 'includes the employment payment type for both client and partner' do
          expect(owners).to contain_exactly 'partner', 'applicant'
          expect(payment_types).to contain_exactly 'employment', 'maintenance'
        end
      end

      context 'when both are employed and full means is required' do
        before do
          allow(MeansStatus).to receive_messages(include_partner?: true, full_means_required?: true)
          income.employment_status = ['employed']
          income.partner_employment_status = ['employed']
        end

        it 'includes the work_benefits payment type for both client and partner' do
          expect(owners).to contain_exactly 'partner', 'applicant'
          expect(payment_types).to contain_exactly 'maintenance', 'work_benefits'
        end
      end

      context 'when both are self-employed and full means is required' do
        before do
          allow(MeansStatus).to receive_messages(include_partner?: true, full_means_required?: true)
          income.employment_status = ['self_employed']
          income.partner_employment_status = ['self_employed']
        end

        it 'includes the work_benefits payment type for both client and partner' do
          expect(owners).to contain_exactly 'partner', 'applicant'
          expect(payment_types).to contain_exactly 'maintenance', 'work_benefits'
        end
      end

      context 'when both are employed but the partner is excluded from means' do
        before do
          allow(MeansStatus).to receive_messages(include_partner?: false, full_means_required?: false)
          income.employment_status = ['employed']
          income.partner_employment_status = ['employed']
        end

        it 'includes the employment payment for just the client' do
          expect(owners).to contain_exactly 'applicant'
          expect(payment_types).to contain_exactly 'employment', 'maintenance'
        end
      end

      context 'when only the partner is employed but is excluded from means' do
        before do
          allow(MeansStatus).to receive_messages(include_partner?: false, full_means_required?: false)
          income.employment_status = ['not_working']
          income.partner_employment_status = ['employed']
        end

        it 'employent payments are still excluded' do
          expect(owners).to contain_exactly 'applicant'
          expect(payment_types).to contain_exactly 'maintenance'
        end
      end

      context 'when full means, both are employed, but partner is excluded' do
        before do
          allow(MeansStatus).to receive_messages(include_partner?: false, full_means_required?: true)
          income.employment_status = ['employed']
          income.partner_employment_status = ['employed']
        end

        it 'includes the work_benefits payment type for client only' do
          expect(owners).to contain_exactly 'applicant'
          expect(payment_types).to contain_exactly 'maintenance', 'work_benefits'
        end
      end
    end
  end

  describe '#client_in_armed_forces' do
    subject(:client_in_armed_forces) { income.client_in_armed_forces }

    before { income.client_in_armed_forces = 'yes' }

    context 'when client_in_armed_forces is required' do
      before { allow(income).to receive(:require_client_in_armed_forces?).and_return(true) }

      it { is_expected.to eq('yes') }
    end

    context 'when client_in_armed_forces is not required' do
      before { allow(income).to receive(:require_client_in_armed_forces?).and_return(false) }

      it { is_expected.to be_nil }
    end
  end

  describe '#partner_in_armed_forces' do
    subject(:partner_in_armed_forces) { income.partner_in_armed_forces }

    before { income.partner_in_armed_forces = 'no' }

    context 'when partner_in_armed_forces is required' do
      before { allow(income).to receive(:require_partner_in_armed_forces?).and_return(true) }

      it { is_expected.to eq('no') }
    end

    context 'when partner_in_armed_forces is not required' do
      before { allow(income).to receive(:require_partner_in_armed_forces?).and_return(false) }

      it { is_expected.to be_nil }
    end
  end
end
