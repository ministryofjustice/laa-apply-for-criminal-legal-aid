RSpec.shared_examples 'a form with a from_subject' do
  describe '#form_subject' do
    subject(:form_subject) { form.form_subject }

    context 'when record is owned by applicant' do
      before { record.ownership_type = 'applicant' }

      it { is_expected.to eq SubjectType::APPLICANT }
    end

    context 'when record is owned by partner' do
      before { record.ownership_type = 'partner' }

      it { is_expected.to eq SubjectType::PARTNER }
    end
  end
end
