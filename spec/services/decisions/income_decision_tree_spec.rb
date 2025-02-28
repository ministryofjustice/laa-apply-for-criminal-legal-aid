require 'rails_helper'

# rubocop:disable RSpec/MultipleMemoizedHelpers, RSpec/NestedGroups
RSpec.describe Decisions::IncomeDecisionTree do
  subject { described_class.new(form_object, as: step_name) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      id: 'uuid',
      income: income,
      dependants: dependants_double,
      client_employments: employments_double,
      partner_employments: partner_employments_double,
      kase: kase,
      partner_detail: partner_detail,
      partner: partner,
      applicant: applicant,
      appeal_no_changes?: false,
      non_means_tested?: false
    )
  end

  let(:applicant) { instance_double(Applicant) }
  let(:partner) { nil }

  let(:employment_double) {
    instance_double(Employment, id: 'uuid1', ownership_type: OwnershipType::APPLICANT.to_s)
  }
  let(:partner_employment_double) {
    instance_double(Employment, id: 'uuid2', ownership_type: OwnershipType::PARTNER.to_s)
  }
  let(:income) do
    instance_double(
      Income,
      employment_status: employment_status,
      partner_employment_status: partner_employment_status,
      client_employments: employments_double,
      partner_employments: partner_employments_double,
      client_self_employed?: false,
      partner_self_employed?: false,
      income_above_threshold: 'yes'
    )
  end

  let(:employment_status) { nil }
  let(:partner_employment_status) { nil }
  let(:dependants_double) { double('dependants_collection') }
  let(:employments_double) {
    double('employments_collection', create!: true,
           reject: incomplete_employments,
           empty?: client_employments_empty?)
  }
  let(:partner_employments_double) {
    double('partner_employments_collection', create!: true,
           reject: partner_incomplete_employments,
           empty?: partner_employments_empty?)
  }
  let(:kase) { instance_double(Case, case_type:) }
  let(:incomplete_employments) { [] }
  let(:partner_incomplete_employments) { [] }

  let(:case_type) { nil }
  let(:partner_detail) { nil }

  let(:partner_employments_empty?) { true }
  let(:client_employments_empty?) { true }

  before do
    allow(
      form_object
    ).to receive(:crime_application).and_return(crime_application)

    allow(subject).to receive(:evidence_of_passporting_means_forthcoming?).and_return(false)
    allow_any_instance_of(Passporting::MeansPassporter).to receive(:call).and_return(false)
  end

  it_behaves_like 'a decision tree'

  context 'when the step is `employment_status`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :employment_status }

    context 'when status selected is an employed option' do
      let(:employment_status) { [EmploymentStatus::EMPLOYED.to_s] }

      before do
        allow(form_object).to receive(:employment_status).and_return([EmploymentStatus::EMPLOYED.to_s])
      end

      context 'and the armed forces question is required' do
        before { allow(income).to receive(:require_client_in_armed_forces?).and_return(true) }

        it 'redirects to the `armed_forces` page' do
          expect(subject).to have_destination(:armed_forces, :edit, id: crime_application, subject: 'client')
        end
      end

      context 'and the armed forces question is not required' do
        before { allow(income).to receive(:require_client_in_armed_forces?).and_return(false) }

        it 'redirects to the `income_before_tax` page' do
          expect(subject).to have_destination(:income_before_tax, :edit, id: crime_application)
        end
      end
    end

    context 'when status selected is self-employed option' do
      let(:employment_status) { [EmploymentStatus::SELF_EMPLOYED.to_s] }

      before do
        allow(form_object).to receive(:employment_status).and_return([EmploymentStatus::SELF_EMPLOYED.to_s])
      end

      context 'when the client has no businesses' do
        before do
          allow(applicant).to receive_messages(businesses: [])
        end

        it 'redirects to the Business type page' do
          expect(subject).to have_destination('/steps/income/business_type',
                                              :edit,
                                              id: crime_application,
                                              subject: applicant)
        end
      end

      context 'when the client has businesses' do
        before do
          allow(applicant).to receive_messages(businesses: [instance_double(Business)])
        end

        it 'redirects to the Business type page' do
          expect(subject).to have_destination('/steps/income/businesses_summary',
                                              :edit,
                                              id: crime_application,
                                              subject: applicant)
        end
      end
    end

    context 'when status selected is both employed and self_employed options' do
      let(:employment_status) { [EmploymentStatus::EMPLOYED.to_s, EmploymentStatus::SELF_EMPLOYED.to_s] }

      before do
        allow(form_object).to receive(:employment_status).and_return(
          [EmploymentStatus::EMPLOYED.to_s, EmploymentStatus::SELF_EMPLOYED.to_s]
        )
      end

      context 'with client employments present' do
        let(:client_employments_empty?) { false }

        it 'redirects to the `client/employments_summary` page' do
          expect(subject).to have_destination('/steps/income/client/employments_summary',
                                              :edit, id: crime_application)
        end
      end

      context 'with client employments not present' do
        let(:client_employments_empty?) { true }

        it 'redirects to the `employer_details` page' do
          expect(subject).to have_destination('/steps/income/client/employer_details',
                                              :edit, id: crime_application)
        end
      end

      context 'with incomplete employments' do
        let(:client_employments_empty?) { true }
        let(:incomplete_employments) { [employment_double] }

        it 'redirects to the `employer_details` page' do
          expect(subject).to have_destination('/steps/income/client/employer_details', :edit, id: crime_application)
          expect(employments_double).not_to have_received(:create!)
        end
      end

      context 'with no incomplete employments' do
        let(:incomplete_employments) { [] }

        it 'redirects to the `employer_details` page' do
          expect(subject).to have_destination('/steps/income/client/employer_details', :edit, id: crime_application)
          expect(employments_double).to have_received(:create!)
        end
      end
    end

    context 'when status selected is not working' do
      let(:employment_status) { EmploymentStatus::NOT_WORKING.to_s }

      context 'when employment ended within 3 months' do
        before do
          allow(form_object).to receive_messages(employment_status: [EmploymentStatus::NOT_WORKING.to_s],
                                                 ended_employment_within_three_months: YesNoAnswer::YES)
        end

        it { is_expected.to have_destination(:lost_job_in_custody, :edit, id: crime_application) }
      end

      context 'when employment has not ended within 3 months' do
        before do
          allow(form_object).to receive_messages(employment_status: [EmploymentStatus::NOT_WORKING.to_s],
                                                 ended_employment_within_three_months: YesNoAnswer::NO)
        end

        let(:case_type) { 'summary_only' }

        it { is_expected.to have_destination(:income_before_tax, :edit, id: crime_application) }
      end
    end
  end

  context 'when the step is `partner_employment_status`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :partner_employment_status }

    context 'when partner_employment_status selected is an employed option' do
      let(:partner_employment_status) { [EmploymentStatus::EMPLOYED.to_s] }

      before do
        allow(form_object).to receive(:partner_employment_status).and_return([EmploymentStatus::EMPLOYED.to_s])
      end

      context 'and the armed forces question is required' do
        before { allow(income).to receive(:require_partner_in_armed_forces?).and_return(true) }

        it 'redirects to the `armed_forces` page' do
          expect(subject).to have_destination(:armed_forces, :edit, id: crime_application, subject: 'partner')
        end
      end

      context 'and the armed forces question is not required' do
        before { allow(income).to receive(:require_partner_in_armed_forces?).and_return(false) }

        context 'when does not requires_full_means_assessment?' do
          before do
            allow_any_instance_of(described_class).to receive(:requires_full_means_assessment?).and_return(false)
          end

          it 'redirects to the `partner/employment_income` page' do
            expect(subject).to have_destination('/steps/income/partner/employment_income', :edit,
                                                id: crime_application)
          end
        end

        context 'when requires_full_means_assessment?' do
          before do
            allow_any_instance_of(described_class).to receive(:requires_full_means_assessment?).and_return(true)
          end

          context 'with partner employments present' do
            let(:partner_employments_empty?) { false }

            it 'redirects to the `partner/employments_summary` page' do
              expect(subject).to have_destination('/steps/income/partner/employments_summary', :edit,
                                                  id: crime_application)
            end
          end

          context 'with incomplete partner employments' do
            let(:partner_employments_empty?) { false }
            let(:partner_incomplete_employments) { [employment_double] }

            it 'redirects to the `partner/employer_details` page' do
              expect(subject).to have_destination('/steps/income/partner/employer_details', :edit,
                                                  id: crime_application)
            end
          end

          context 'with partner employments not present' do
            let(:partner_employments_empty?) { true }

            it 'redirects to the `partner/employer_details` page' do
              expect(subject).to have_destination('/steps/income/partner/employer_details', :edit,
                                                  id: crime_application)
            end
          end
        end
      end
    end

    context 'when partner_employment_status selected is self-employed option' do
      let(:partner_employment_status) { [EmploymentStatus::SELF_EMPLOYED.to_s] }

      before do
        allow(form_object).to receive(:partner_employment_status).and_return([EmploymentStatus::SELF_EMPLOYED.to_s])
      end

      context 'when the partner has no businesses' do
        let(:partner) { instance_double(Partner, businesses: []) }

        it 'redirects to the Business type page' do
          expect(subject).to have_destination('/steps/income/business_type',
                                              :edit,
                                              id: crime_application,
                                              subject: partner)
        end
      end

      context 'when the partner already has businesses' do
        let(:partner) { instance_double(Partner, businesses: [instance_double(Business)]) }

        it 'redirects to the partner Business summary page' do
          expect(subject).to have_destination('/steps/income/businesses_summary',
                                              :edit,
                                              id: crime_application,
                                              subject: partner)
        end
      end
    end

    context 'when partner_employment_status selected is both employed and self_employed options' do
      let(:partner) { instance_double(Partner, businesses: []) }

      before do
        allow(form_object).to receive(:partner_employment_status).and_return(
          [EmploymentStatus::EMPLOYED.to_s, EmploymentStatus::SELF_EMPLOYED.to_s]
        )
      end

      context 'with partner employments present' do
        let(:partner_employments_empty?) { true }

        it 'redirects to the `partner/employer_details` page' do
          expect(subject).to have_destination('/steps/income/partner/employer_details', :edit, id: crime_application)
        end
      end

      context 'with partner employments not present' do
        let(:partner_employments_empty?) { false }

        it 'redirects to the `partner/employments_summary` page' do
          expect(subject).to have_destination('/steps/income/partner/employments_summary', :edit,
                                              id: crime_application)
        end
      end

      context 'with incomplete employments' do
        let(:partner_employments_empty?) { false }
        let(:partner_incomplete_employments) { [partner_employment_double] }

        it 'redirects to the `partner_employer_details` page' do
          expect(subject).to have_destination('/steps/income/partner/employer_details', :edit, id: crime_application)
          expect(partner_employments_double).not_to have_received(:create!)
        end
      end

      context 'with no incomplete employments' do
        let(:partner_employments_empty?) { true }
        let(:partner_incomplete_employments) { [] }

        it 'redirects to the `partner_employer_details` page' do
          expect(subject).to have_destination('/steps/income/partner/employer_details', :edit, id: crime_application)
          expect(partner_employments_double).to have_received(:create!)
        end
      end
    end

    context 'when status selected is not working' do
      let(:partner_employment_status) { EmploymentStatus::NOT_WORKING.to_s }

      before do
        allow(form_object).to receive(:partner_employment_status).and_return([EmploymentStatus::NOT_WORKING.to_s])
      end

      it 'redirects to the `income_payments_partner` page' do
        expect(subject).to have_destination(:income_payments_partner, :edit, id: crime_application)
      end
    end
  end

  context 'when the step is `armed_forces`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :armed_forces }

    context 'and the form subject is client' do
      before do
        allow(
          form_object
        ).to receive(:form_subject).and_return(SubjectType::APPLICANT)
      end

      it 'redirects to the `income_before_tax` page' do
        expect(subject).to have_destination(:income_before_tax, :edit, id: crime_application)
      end
    end

    context 'and the form subject is partner' do
      before do
        allow(
          form_object
        ).to receive(:form_subject).and_return(SubjectType::PARTNER)
      end

      context 'when does not requires_full_means_assessment?' do
        before do
          allow_any_instance_of(described_class).to receive(:requires_full_means_assessment?).and_return(false)
        end

        it 'redirects to the `partner/employment_income` page' do
          expect(subject).to have_destination('/steps/income/partner/employment_income', :edit,
                                              id: crime_application)
        end
      end

      context 'when requires_full_means_assessment?' do
        before do
          allow_any_instance_of(described_class).to receive(:requires_full_means_assessment?).and_return(true)
        end

        context 'with partner employments present' do
          let(:partner_employments_empty?) { false }

          it 'redirects to the `partner/employments_summary` page' do
            expect(subject).to have_destination('/steps/income/partner/employments_summary', :edit,
                                                id: crime_application)
          end
        end

        context 'with incomplete partner employments' do
          let(:partner_employments_empty?) { false }
          let(:partner_incomplete_employments) { [employment_double] }

          it 'redirects to the `partner/employer_details` page' do
            expect(subject).to have_destination('/steps/income/partner/employer_details', :edit,
                                                id: crime_application)
          end
        end

        context 'with partner employments not present' do
          let(:partner_employments_empty?) { true }

          it 'redirects to the `partner/employer_details` page' do
            expect(subject).to have_destination('/steps/income/partner/employer_details', :edit,
                                                id: crime_application)
          end
        end
      end
    end
  end

  context 'when the step is `income_payments_partner`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :income_payments_partner }

    it { is_expected.to have_destination(:income_benefits_partner, :edit, id: crime_application) }
  end

  context 'when the step is `income_benefits_partner`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :income_benefits_partner }

    context 'when there is sufficient income' do
      before { allow(subject).to receive(:insufficient_income_declared?).and_return(false) }

      it { is_expected.to have_destination(:answers, :edit, id: crime_application) }
    end

    context 'when there is insufficient income' do
      before { allow(subject).to receive(:insufficient_income_declared?).and_return(true) }

      it { is_expected.to have_destination(:manage_without_income, :edit, id: crime_application) }
    end
  end

  context 'client employment`' do
    context 'when the step is `client_employer_details`' do
      let(:form_object) do
        double('FormObject', record: employment_double)
      end
      let(:step_name) { :client_employer_details }

      it 'redirects to `client_employer_details` page' do
        expect(subject).to have_destination('steps/income/client/employment_details', :edit, id: crime_application)
      end
    end

    context 'when the step is `client_employment_details`' do
      let(:form_object) do
        double('FormObject', record: employment_double)
      end
      let(:step_name) { :client_employment_details }

      it 'redirects to `client deductions` page' do
        expect(subject).to have_destination('/steps/income/client/deductions', :edit, id: crime_application)
      end
    end

    context 'when the step is `client_deductions`' do
      let(:form_object) do
        double('FormObject', record: employment_double)
      end
      let(:step_name) { :client_deductions }

      it 'redirects to `client employments_summary` page' do
        expect(subject).to have_destination('/steps/income/client/employments_summary', :edit, id: crime_application)
      end
    end

    context 'when the step is `client_employments_summary`' do
      let(:form_object) { double('FormObject', record: employment_double) }
      let(:step_name) { :client_employments_summary }

      before do
        allow(form_object).to receive_messages(crime_application:, add_client_employment:)
      end

      context 'the client has selected yes to adding an employment' do
        let(:add_client_employment) { YesNoAnswer::YES }

        it 'redirects to the edit `client_employer_details` page' do
          expect(subject).to have_destination('/steps/income/client/employer_details', :edit, id: crime_application)
        end
      end

      context 'the client has selected no to adding an employment' do
        let(:add_client_employment) { YesNoAnswer::NO }

        context 'and there are no self employments to add' do
          let(:employment_status) { [EmploymentStatus::EMPLOYED.to_s] }

          it 'redirects to client self_assessment_tax_bill page' do
            expect(subject).to have_destination(
              '/steps/income/client/self_assessment_tax_bill', :edit, id: crime_application
            )
          end
        end

        context 'and there are self employments to add' do
          let(:employment_status) { [EmploymentStatus::EMPLOYED.to_s, EmploymentStatus::SELF_EMPLOYED.to_s] }

          before do
            allow(applicant).to receive_messages(businesses: [])
          end

          it 'redirects to the Business type page' do
            expect(subject).to have_destination('/steps/income/business_type',
                                                :edit,
                                                id: crime_application,
                                                subject: applicant)
          end
        end
      end
    end
  end

  context 'partner employment`' do
    context 'when the step is `partner_employer_details`' do
      let(:form_object) do
        double('FormObject', record: partner_employment_double)
      end
      let(:step_name) { :partner_employer_details }

      it 'redirects to `partner_employer_details` page' do
        expect(subject).to have_destination(
          'steps/income/partner/employment_details', :edit, id: crime_application
        )
      end
    end

    context 'when the step is `partner_employment_details`' do
      let(:form_object) do
        double('FormObject', record: partner_employment_double)
      end
      let(:step_name) { :partner_employment_details }

      it 'redirects to `partner deductions` page' do
        expect(subject).to have_destination('/steps/income/partner/deductions', :edit, id: crime_application)
      end
    end

    context 'when the step is `partner_deductions`' do
      let(:form_object) do
        double('FormObject', record: partner_employment_double)
      end
      let(:step_name) { :partner_deductions }

      it 'redirects to `partner employments_summary` page' do
        expect(subject).to have_destination('/steps/income/partner/employments_summary', :edit, id: crime_application)
      end
    end

    context 'when the step is `partner_employments_summary`' do
      let(:form_object) { double('FormObject', record: partner_employment_double) }
      let(:step_name) { :partner_employments_summary }

      before do
        allow(form_object).to receive_messages(crime_application:, add_partner_employment:)
      end

      context 'the partner has selected yes to adding an employment' do
        let(:add_partner_employment) { YesNoAnswer::YES }

        it 'redirects to the edit `partner employer details` page' do
          expect(subject).to have_destination('/steps/income/partner/employer_details', :edit, id: crime_application)
        end
      end

      context 'the partner has selected no to adding an employment' do
        let(:add_partner_employment) { YesNoAnswer::NO }

        context 'and there are no self employments to add' do
          let(:partner_employment_status) { [EmploymentStatus::EMPLOYED.to_s] }

          it 'redirects to partner self_assessment_tax_bill page' do
            expect(subject).to have_destination(
              '/steps/income/partner/self_assessment_tax_bill', :edit, id: crime_application
            )
          end
        end

        context 'and there are self employments to add' do
          let(:partner_employment_status) { [EmploymentStatus::EMPLOYED.to_s, EmploymentStatus::SELF_EMPLOYED.to_s] }

          before do
            allow(partner).to receive_messages(businesses: [])
          end

          it 'redirects to the Business type page' do
            expect(subject).to have_destination('/steps/income/business_type',
                                                :edit,
                                                id: crime_application,
                                                subject: partner)
          end
        end
      end
    end
  end

  context 'when the step is `lost_job_in_custody`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :lost_job_in_custody }
    let(:case_type) { 'summary_only' }

    it { is_expected.to have_destination(:income_before_tax, :edit, id: crime_application) }
  end

  context 'when the step is `income_before_tax`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :income_before_tax }
    let(:case_type) { 'committal' }

    before do
      allow(income).to receive_messages(
        income_above_threshold: income_above_threshold,
        has_frozen_income_or_assets: nil,
        client_owns_property: nil,
        has_savings: nil
      )
    end

    context 'when income is above the threshold' do
      let(:income_above_threshold) { YesNoAnswer::YES.to_s }

      context 'when the client is employed' do
        let(:employment_status) { [EmploymentStatus::EMPLOYED.to_s] }

        it { is_expected.to have_destination('/steps/income/client/employer_details', :edit, id: crime_application) }
      end

      context 'when the client is not employed' do
        let(:employment_status) { [EmploymentStatus::NOT_WORKING.to_s] }

        it { is_expected.to have_destination(:income_payments, :edit, id: crime_application) }
      end
    end

    context 'when income below the threshold' do
      let(:income_above_threshold) { YesNoAnswer::NO.to_s }

      it { is_expected.to have_destination(:frozen_income_savings_assets, :edit, id: crime_application) }
    end
  end

  context 'when the step is `frozen_income_savings_assets`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :frozen_income_savings_assets }

    before do
      allow(income).to receive_messages(
        income_above_threshold: 'no',
        has_frozen_income_or_assets: has_frozen_income_or_assets,
        client_owns_property: nil,
        has_savings: nil
      )
    end

    context 'when they do not have frozen income or assets' do
      let(:has_frozen_income_or_assets) { YesNoAnswer::NO.to_s }

      context 'when case type is summary only' do
        let(:case_type) { 'summary_only' }

        context 'when the client is employed' do
          let(:employment_status) { EmploymentStatus::EMPLOYED.to_s }

          it 'redirects to the `employment_income` page' do
            expect(subject).to have_destination('/steps/income/client/employment_income', :edit, id: crime_application)
          end
        end

        context 'when the client is not employed' do
          let(:employment_status) { EmploymentStatus::NOT_WORKING.to_s }

          it { is_expected.to have_destination(:income_payments, :edit, id: crime_application) }
        end
      end

      context 'when case type is committal' do
        let(:case_type) { 'committal' }

        context 'when the client is employed' do
          let(:employment_status) { EmploymentStatus::EMPLOYED.to_s }

          it 'redirects to the `employment_income` page' do
            expect(subject).to have_destination('/steps/income/client/employment_income', :edit, id: crime_application)
          end
        end

        context 'when the client is not employed' do
          let(:employment_status) { EmploymentStatus::NOT_WORKING.to_s }

          it { is_expected.to have_destination(:income_payments, :edit, id: crime_application) }
        end
      end

      context 'when case type is not summary only or committal' do
        let(:case_type) { 'indictable' }

        context "and the client's usual residence is not owned" do
          let(:applicant) { instance_double(Applicant, residence_type: ResidenceType::RENTED.to_s) }

          it { is_expected.to have_destination(:client_owns_property, :edit, id: crime_application) }
        end

        context "and the client's usual residence is owned" do
          let(:applicant) { instance_double(Applicant, residence_type: ResidenceType::APPLICANT_OWNED.to_s) }

          context 'and the client is employed' do
            let(:employment_status) { EmploymentStatus::EMPLOYED.to_s }

            it 'redirects to the `employer_details` page' do
              expect(subject).to have_destination('/steps/income/client/employer_details', :edit,
                                                  id: crime_application)
            end
          end

          context 'and the client is not employed' do
            let(:employment_status) { EmploymentStatus::NOT_WORKING.to_s }

            it { is_expected.to have_destination(:income_payments, :edit, id: crime_application) }
          end
        end
      end
    end

    context 'when they have frozen income or assets' do
      let(:has_frozen_income_or_assets) { YesNoAnswer::YES.to_s }

      context 'when the client is employed' do
        let(:employment_status) { EmploymentStatus::EMPLOYED.to_s }

        context 'with client employments present' do
          let(:client_employments_empty?) { true }

          it 'redirects to the `client/employer_details` page' do
            expect(subject).to have_destination('/steps/income/client/employer_details', :edit, id: crime_application)
          end
        end

        context 'with incomplete client employments' do
          let(:client_employments_empty?) { true }
          let(:incomplete_employments) { [employment_double] }

          it 'redirects to the `employer_details` page' do
            expect(subject).to have_destination('/steps/income/client/employer_details', :edit, id: crime_application)
            expect(employments_double).not_to have_received(:create!)
          end
        end

        context 'with client employments not present' do
          let(:client_employments_empty?) { false }

          it 'redirects to the `client/employments_summary` page' do
            expect(subject).to have_destination('/steps/income/client/employments_summary', :edit,
                                                id: crime_application)
          end
        end
      end

      context 'when the client is not employed' do
        let(:employment_status) { EmploymentStatus::NOT_WORKING.to_s }

        it { is_expected.to have_destination(:income_payments, :edit, id: crime_application) }
      end
    end
  end

  context 'when the step is `client_owns_property`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :client_owns_property }

    before do
      allow(income).to receive_messages(
        income_above_threshold: 'no',
        has_frozen_income_or_assets: 'no',
        client_owns_property: client_owns_property,
        has_savings: nil
      )
      allow(applicant).to receive(:residence_type).and_return(ResidenceType::RENTED.to_s)
    end

    context 'when they do not have property' do
      let(:client_owns_property) { YesNoAnswer::NO.to_s }

      it { is_expected.to have_destination(:has_savings, :edit, id: crime_application) }
    end

    context 'when they have property' do
      let(:client_owns_property) { YesNoAnswer::YES.to_s }

      context 'when the client is employed' do
        let(:employment_status) { EmploymentStatus::EMPLOYED.to_s }

        context 'with client employments present' do
          let(:client_employments_empty?) { false }

          it 'redirects to the `client/employments_summary` page' do
            expect(subject).to have_destination('/steps/income/client/employments_summary', :edit,
                                                id: crime_application)
          end
        end

        context 'with incomplete employments' do
          let(:client_employments_empty?) { true }
          let(:incomplete_employments) { [employment_double] }

          it 'redirects to the `employer_details` page' do
            expect(subject).to have_destination('/steps/income/client/employer_details', :edit, id: crime_application)
            expect(employments_double).not_to have_received(:create!)
          end
        end

        context 'with client employments not present' do
          let(:client_employments_empty?) { true }

          it 'redirects to the `client/employer_details` page' do
            expect(subject).to have_destination('/steps/income/client/employer_details', :edit, id: crime_application)
          end
        end
      end

      context 'when the client is not employed' do
        let(:employment_status) { EmploymentStatus::NOT_WORKING.to_s }

        it { is_expected.to have_destination(:income_payments, :edit, id: crime_application) }
      end
    end
  end

  context 'when the step is `has savings`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :has_savings }

    context 'when the client is not employed' do
      let(:employment_status) { ['not_working'] }

      it { is_expected.to have_destination(:income_payments, :edit, id: crime_application) }
    end

    context 'when the client is employed' do
      let(:employment_status) { ['employed'] }

      context 'when they have savings' do
        before { allow(subject).to receive(:requires_full_means_assessment?).and_return(true) }

        context 'with client employments present' do
          let(:client_employments_empty?) { false }

          before do
            allow(income).to receive(:client_employments).and_return(employments_double)
          end

          it 'redirects to the `client/employments_summary` page' do
            expect(subject).to have_destination('/steps/income/client/employments_summary', :edit,
                                                id: crime_application)
          end
        end

        context 'with incomplete employments' do
          let(:client_employments_empty?) { true }
          let(:incomplete_employments) { [employment_double] }

          it 'redirects to the `employer_details` page' do
            expect(subject).to have_destination('/steps/income/client/employer_details', :edit, id: crime_application)
            expect(employments_double).not_to have_received(:create!)
          end
        end

        context 'with client employments not present' do
          let(:client_employments_empty?) { true }

          it 'redirects to the `client/employer_details` page' do
            expect(subject).to have_destination('/steps/income/client/employer_details', :edit, id: crime_application)
          end
        end
      end

      context 'when they do not have savings' do
        before { allow(subject).to receive(:requires_full_means_assessment?).and_return(false) }

        it 'redirects to the `employment_income` page' do
          expect(subject).to have_destination('/steps/income/client/employment_income', :edit, id: crime_application)
        end
      end
    end
  end

  context 'when the step is `client_employment_income`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :client_employment_income }

    it { is_expected.to have_destination('/steps/income/income_payments', :edit, id: crime_application) }
  end

  context 'when the step is `partner_employment_income`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :partner_employment_income }

    it { is_expected.to have_destination('/steps/income/income_payments_partner', :edit, id: crime_application) }
  end

  context 'when the step is `client_self_assessment_tax_bill`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :client_self_assessment_tax_bill }

    it { is_expected.to have_destination(:other_work_benefits, :edit, id: crime_application) }
  end

  context 'when the step is `partner_self_assessment_tax_bill`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :partner_self_assessment_tax_bill }

    it { is_expected.to have_destination(:other_work_benefits, :edit, id: crime_application) }
  end

  context 'when the step is `client_other_work_benefits`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :client_other_work_benefits }

    it { is_expected.to have_destination('/steps/income/income_payments', :edit, id: crime_application) }
  end

  context 'when the step is `partner_other_work_benefits`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :partner_other_work_benefits }

    it { is_expected.to have_destination('/steps/income/income_payments_partner', :edit, id: crime_application) }
  end

  context 'when the step is `income payments`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :income_payments }

    context 'has correct next step' do
      it { is_expected.to have_destination(:income_benefits, :edit, id: crime_application) }
    end
  end

  context 'when the step is `income benefits`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :income_benefits }

    before do
      allow(subject).to receive(:requires_full_means_assessment?).and_return(requires_full_means_assessment)
    end

    context 'when full means assessment needs completing' do
      let(:requires_full_means_assessment) { true }

      it { is_expected.to have_destination(:client_has_dependants, :edit, id: crime_application) }
    end

    context 'when does not require full means assessment' do
      let(:requires_full_means_assessment) { false }

      context 'when there is sufficient income' do
        before { allow(subject).to receive(:insufficient_income_declared?).and_return(false) }

        it { is_expected.to have_destination(:answers, :edit, id: crime_application) }
      end

      context 'when there is insufficient income' do
        before { allow(subject).to receive(:insufficient_income_declared?).and_return(true) }

        it { is_expected.to have_destination(:manage_without_income, :edit, id: crime_application) }
      end
    end
  end

  context 'when the step is `client_has_dependants`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :client_has_dependants }

    context 'when client does not have dependants' do
      before do
        allow(form_object).to receive(:client_has_dependants).and_return(YesNoAnswer::NO)
      end

      context 'when there is sufficient income' do
        before { allow(subject).to receive(:insufficient_income_declared?).and_return(false) }

        it { is_expected.to have_destination(:answers, :edit, id: crime_application) }
      end

      context 'when there is insufficient income' do
        before { allow(subject).to receive(:insufficient_income_declared?).and_return(true) }

        it { is_expected.to have_destination(:manage_without_income, :edit, id: crime_application) }
      end
    end

    context 'when client does have dependants and no stored dependants' do
      let(:dependants_double) { double('dependants_collection', empty?: true) }

      before do
        allow(form_object).to receive(:client_has_dependants).and_return(YesNoAnswer::YES)
        allow(dependants_double).to receive(:none?).and_return(true)
      end

      it 'creates a blank dependant record and redirects to the dependants page' do
        expect(dependants_double).to receive(:create!).at_least(:once)

        expect(subject).to have_destination(:dependants, :edit, id: crime_application)
      end
    end

    context 'when client does have dependants and has stored dependants' do
      let(:dependants_double) { double('dependants_collection', empty?: false) }

      before do
        allow(form_object).to receive(:client_has_dependants).and_return(YesNoAnswer::YES)
        allow(dependants_double).to receive(:none?).and_return(false)
      end

      it 'does not create a blank dependant record and redirects to the dependants page' do
        expect(dependants_double).not_to receive(:create!)

        expect(subject).to have_destination(:dependants, :edit, id: crime_application)
      end
    end
  end

  context 'when the step is `add_dependant`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :add_dependant }

    it 'creates a blank dependant record and redirects to the dependants page' do
      expect(dependants_double).to receive(:create!).at_least(:once)
      expect(subject).to have_destination(:dependants, :edit, id: crime_application)
    end
  end

  context 'when the step is `delete_dependant`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :delete_dependant }

    # Technically the interface will not allow this possibility as we don't allow
    # deleting the last remaining record, but the test exists as a sanity check.
    # (See Codefendants behaviour/UX)
    context 'and there are no other dependants left' do
      let(:dependants_double) { double('dependants_collection', empty?: true) }

      it 'creates a blank dependant record and redirects to the dependants page' do
        expect(dependants_double).to receive(:create!).at_least(:once)
        expect(subject).to have_destination(:dependants, :edit, id: crime_application)
      end
    end

    context 'and there are other dependants left' do
      let(:dependants_double) { double('dependants_collection', empty?: false) }

      it 'redirects to the dependants page' do
        expect(subject).to have_destination(:dependants, :edit, id: crime_application)
      end
    end
  end

  context 'when the step is `dependants_finished`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :dependants_finished }

    context 'when the partner is included in means assessment' do
      let(:partner_detail) { double(PartnerDetail, involvement_in_case: 'none') }

      it { is_expected.to have_destination(:partner_employment_status, :edit, id: crime_application) }
    end

    context 'when there is sufficient income' do
      before { allow(subject).to receive(:insufficient_income_declared?).and_return(false) }

      it { is_expected.to have_destination(:answers, :edit, id: crime_application) }
    end

    context 'when there is insufficient income' do
      before { allow(subject).to receive(:insufficient_income_declared?).and_return(true) }

      it { is_expected.to have_destination(:manage_without_income, :edit, id: crime_application) }
    end
  end

  context 'when the step is `manage_without_income`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :manage_without_income }

    before do
      allow(income).to receive_messages(
        income_above_threshold:,
        has_frozen_income_or_assets:,
        client_owns_property:,
        has_savings:
      )
    end

    context 'when full means assessment needs completing' do
      let(:income_above_threshold) { YesNoAnswer::YES.to_s }
      let(:has_frozen_income_or_assets) { YesNoAnswer::NO.to_s }
      let(:client_owns_property) { YesNoAnswer::NO.to_s }
      let(:has_savings) { YesNoAnswer::NO.to_s }

      it { is_expected.to have_destination(:answers, :edit, id: crime_application) }
    end

    context 'when full means assessment does not need completing' do
      let(:income_above_threshold) { YesNoAnswer::NO.to_s }
      let(:has_frozen_income_or_assets) { YesNoAnswer::NO.to_s }
      let(:client_owns_property) { YesNoAnswer::NO.to_s }
      let(:has_savings) { YesNoAnswer::NO.to_s }

      it { is_expected.to have_destination(:answers, :edit, id: crime_application) }
    end
  end

  context 'when the step is `answers`' do
    before do
      allow(crime_application).to receive(:navigation_stack).and_return(navigation_stack)
    end

    let(:form_object) { double('FormObject') }
    let(:destination_url) {
      Rails.application.routes.url_helpers.edit_steps_income_answers_path(id: crime_application.id)
    }
    let(:step_name) { :answers }
    let(:navigation_stack) {
      [
        source_url,
        destination_url
      ]
    }

    context "when source is 'employment_status' path" do
      let(:source_url) {
        Rails.application.routes.url_helpers.edit_steps_income_employment_status_path(id: crime_application.id)
      }

      it { is_expected.to have_destination('/steps/evidence/upload', :edit, id: crime_application) }
    end

    context "when source is 'lost_job_in_custody' path" do
      let(:source_url) {
        Rails.application.routes.url_helpers.edit_steps_income_lost_job_in_custody_path(id: crime_application.id)
      }

      it { is_expected.to have_destination('/steps/evidence/upload', :edit, id: crime_application) }
    end

    context "when source is 'manage_without_income'" do
      before do
        allow(subject).to receive(:requires_full_means_assessment?).and_return(requires_full_means_assessment)
      end

      let(:source_url) {
        Rails.application.routes.url_helpers.edit_steps_income_manage_without_income_path(crime_application)
      }

      context 'when full means assessment needs completing' do
        let(:requires_full_means_assessment) { true }

        it { is_expected.to have_destination('/steps/outgoings/housing_payment_type', :edit, id: crime_application) }
      end

      context 'when full means assessment does not needs completing' do
        let(:requires_full_means_assessment) { false }

        it { is_expected.to have_destination('/steps/evidence/upload', :edit, id: crime_application) }
      end
    end
  end
end

# rubocop:enable RSpec/MultipleMemoizedHelpers, RSpec/NestedGroups
