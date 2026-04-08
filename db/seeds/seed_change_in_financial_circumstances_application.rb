now = Time.zone.now

# -----------------------------------------------------------------------------
# Crime application – change_in_financial_circumstances
# cifc? = true unlocks:
#   - ioj_present? returns true (no IOJ record needed)
#   - InterestsOfJustice::AnswersValidator not applicable (no IOJ section)
#   - means_valid? returns true (ApplicationFulfilmentValidator)
#   - ApplicationFulfilmentValidator checks cifc_reference_complete? + cifc_reason_complete?
#   - Case validator skips charges, hearing, codefendants, other_charges
# -----------------------------------------------------------------------------

app = CrimeApplication.create!(
  status: 'in_progress',
  application_type: 'change_in_financial_circumstances',
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
  date_stamp: now,
  # Pre-CIFC reference – required by Circumstances::AnswersValidator and
  # ApplicationFulfilmentValidator#cifc_reference_complete? / cifc_reason_complete?
  pre_cifc_reference_number: 'pre_cifc_maat_id',
  pre_cifc_maat_id: '1234567',
  pre_cifc_reason: 'Client became unemployed since original application was submitted'
)

# -----------------------------------------------------------------------------
# Applicant – full client details required; CIFC does not skip address or NINO
# benefit_type: 'none' → PassportingBenefitCheck.complete? returns true immediately
# -----------------------------------------------------------------------------

applicant = Applicant.create!(
  crime_application: app,
  first_name: 'Cifc',
  last_name: 'Applicant',
  date_of_birth: Date.new(1978, 4, 23),
  telephone_number: '07000000003',
  correspondence_address_type: CorrespondenceType::HOME_ADDRESS,
  preferred_correspondence_language: 'english',
  has_nino: 'yes',
  nino: 'JW999003A',
  residence_type: 'rented',
  benefit_type: 'none'
)

HomeAddress.create!(
  person: applicant,
  address_line_one: '22 Finance Road',
  city: 'Leeds',
  country: 'UK',
  postcode: 'LS1 1AA'
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
# Case – no charges, no hearing fields; CaseDetails validator wraps these in
# `unless crime_application.cifc?` so they are entirely skipped
# -----------------------------------------------------------------------------

kase = Case.create!(
  crime_application: app,
  case_type: CaseType::EITHER_WAY.to_s,
  has_case_concluded: 'no',
  is_client_remanded: 'no',
)

# cifc? = true → ioj_present? returns true without an Ioj record;
# IojPassporter and MeansPassporter still run to compute passport arrays
Passporting::IojPassporter.new(app).call
Passporting::MeansPassporter.new(app).call

# -----------------------------------------------------------------------------
# Partner details – partner_information_not_required? = false for CIFC
# (only age_passported?, non_means_tested?, and appeal_no_changes? skip this)
# -----------------------------------------------------------------------------

PartnerDetail.create!(
  crime_application: app,
  has_partner: 'no',
  relationship_status: ClientRelationshipStatusType::SINGLE,
)

# -----------------------------------------------------------------------------
# Income – requires_means_assessment? = true for CIFC (no passporting)
# Using not_working employment to keep the seed minimal:
#   - income_above_threshold: 'no'      → income_before_tax_complete?
#   - has_frozen_income_or_assets: 'no' → frozen_income_savings_assets_complete?
#   - ended_employment_within_three_months: 'no' → not_working_details_complete?
#   - has_no_income_payments: 'yes'     → income_payments_complete?
#   - has_no_income_benefits: 'yes'     → income_benefits_complete?
#   - manage_without_income present     → manage_without_income_complete?
#     (insufficient_income_declared? = true when all_income_over_zero? = false)
# requires_full_means_assessment? = false (below threshold, rented, no capital)
# → outgoings and capital sections are not required
# -----------------------------------------------------------------------------

Income.create!(
  crime_application: app,
  employment_status: ['not_working'],
  income_above_threshold: 'no',
  has_frozen_income_or_assets: 'no',
  ended_employment_within_three_months: 'no',
  has_no_income_payments: 'yes',
  has_no_income_benefits: 'yes',
  manage_without_income: 'family',
  # required so requires_full_means_assessment? can determine outcome without raising
  # CannotYetDetermineFullMeans (nil values leave it indeterminate)
  client_owns_property: 'no',
  has_savings: 'no',
)

# -----------------------------------------------------------------------------
# Supporting evidence
# evidence_required? = true for CIFC apps regardless of prompts (record.cifc? = true)
# A stored document is therefore always required for evidence_upload_complete?
# -----------------------------------------------------------------------------

Document.create!(
  crime_application: app,
  filename: 'financial_change_evidence.pdf',
  content_type: 'application/pdf',
  declared_content_type: 'application/pdf',
  file_size: 50.kilobytes,
  s3_object_key: "documents/#{app.id}/financial_change_evidence.pdf",
  scan_status: 'pass',
  submitted_at: nil,
  annotations: {}
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
# Declaration – no partner in means assessment, partner declaration not required
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
