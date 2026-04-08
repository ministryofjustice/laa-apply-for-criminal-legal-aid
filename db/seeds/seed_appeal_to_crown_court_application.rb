now = Time.zone.now

# -----------------------------------------------------------------------------
# Crime application
# appeal_to_crown_court case_type with appeal_no_changes? = true unlocks:
#   - means_valid? returns true immediately (no income/capital/outgoings needed)
#   - address_complete? returns true (no residence_type or HomeAddress needed)
#   - has_nino_complete? returns true (NINO skipped)
#   - partner_information_not_required? returns true (no PartnerDetail needed)
#   - PassportingBenefitCheck not applicable
# -----------------------------------------------------------------------------

app = CrimeApplication.create!(
  status: 'in_progress',
  application_type: 'initial',
  is_means_tested: 'yes',
  office_code: '1A123B',
  provider_details: {
    office_code: '1A123B',
    provider_email: 'provider@example.com',
    provider_name: 'Local Dev Provider'
  },
  means_passport: [],
  evidence_prompts: [],
  evidence_last_run_at: nil,
  date_stamp: now
)

# -----------------------------------------------------------------------------
# Applicant – only name and DOB required for appeal_no_changes?
# address_complete? and has_nino_complete? both return true without these fields
# -----------------------------------------------------------------------------

applicant = Applicant.create!(
  crime_application: app,
  first_name: 'Appeal No Changes',
  last_name: 'Applicant',
  date_of_birth: Date.new(1982, 9, 12),
)

app.update!(
  date_stamp_context: DateStampContext.new(
    first_name: applicant.first_name,
    last_name: applicant.last_name,
    date_of_birth: applicant.date_of_birth,
    date_stamp: now
  )
)

# -----------------------------------------------------------------------------
# Case – appeal_to_crown_court with no financial changes
# CaseDetails::AnswersValidator skips charges/hearing ONLY for cifc?, not appeals.
# Appeal cases still need: charges (original offence), hearing details, codefendants.
# AppealDetails::AnswersValidator requires:
#   - appeal_lodged_date (general_details_complete?)
#   - appeal_original_app_submitted (general_details_complete?)
# appeal_no_changes? = true when original submitted + financial_circumstances_changed = 'no'
# appeal_reference_number/appeal_maat_id are required to track the original application
# -----------------------------------------------------------------------------

kase = Case.create!(
  crime_application: app,
  case_type: CaseType::APPEAL_TO_CROWN_COURT.to_s,
  has_case_concluded: 'no',
  is_client_remanded: 'no',
  has_codefendants: 'no',
  hearing_court_name: 'Crown Court at Southwark',
  hearing_date: Date.today + 21,
  is_first_court_hearing: 'yes',
  appeal_lodged_date: Date.today - 60,
  appeal_original_app_submitted: 'yes',
  appeal_financial_circumstances_changed: 'no',
  appeal_reference_number: 'appeal_maat_id',
  appeal_maat_id: '1234567'
)

charge = kase.charges.create!(offence_name: 'Theft')
charge.offence_dates.first.update!(
  date_from: Date.today - 90,
  date_to: Date.today - 90
)

# IojPassporter returns false for appeal case types (no age/offence passporting)
# MeansPassporter returns false (no benefit_check_result; not needed as appeal_no_changes skips means)
Passporting::IojPassporter.new(app).call
Passporting::MeansPassporter.new(app).call

# -----------------------------------------------------------------------------
# IOJ – required; appeals are never IOJ-passported (IojPassporter.passported? = false)
# ApplicationFulfilmentValidator checks ioj_present? = record.ioj.present? && types.any?
# -----------------------------------------------------------------------------

Ioj.create!(
  case: kase,
  types: ['loss_of_liberty'],
  loss_of_liberty_justification: 'Client faces immediate custody if appeal fails'
)

# -----------------------------------------------------------------------------
# More information – no additional information required
# -----------------------------------------------------------------------------

Steps::Submission::MoreInformationForm.new(
  crime_application: app,
  additional_information_required: 'no'
).save!

# -----------------------------------------------------------------------------
# Review form
# -----------------------------------------------------------------------------

app.reload

form = Steps::Submission::ReviewForm.build(app)
raise "ReviewForm validation failed: #{form.errors.full_messages.join(', ')}" unless form.save

# -----------------------------------------------------------------------------
# Provider (for declaration)
# -----------------------------------------------------------------------------

provider = Provider.create!(
  auth_provider: Random.rand(1000).to_s,
  uid: Random.rand(1000).to_s,
  email: 'provider@example.com',
  office_codes: ['1A123B'],
  roles: ['provider'],
)

# -----------------------------------------------------------------------------
# Declaration
# -----------------------------------------------------------------------------

Steps::Submission::DeclarationForm.new(
  crime_application: app,
  record: provider,
  legal_rep_first_name: 'Test',
  legal_rep_last_name: 'Rep',
  legal_rep_telephone: '1234567890'
).save!

puts "Seeded crime application id=#{app.id} usn=#{app.usn}"
puts "Seeded applicant=#{applicant.first_name} #{applicant.last_name}"
