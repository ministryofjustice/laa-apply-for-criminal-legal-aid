now = Time.zone.now

# -----------------------------------------------------------------------------
# Crime application
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
# Applicant with Nino
# -----------------------------------------------------------------------------

applicant = Applicant.create!(
  crime_application: app,
  first_name: "Full means assessed",
  last_name: "Applicant",
  date_of_birth: Date.new(1990, 1, 1),
  telephone_number: '07000000000',
  correspondence_address_type: CorrespondenceType::OTHER_ADDRESS,
  preferred_correspondence_language: 'english',
  has_nino: 'yes',
  nino: 'JW123456C',
  residence_type: 'rented',
  benefit_type: 'none'
)

HomeAddress.create!(
  person: applicant,
  address_line_one: '1 High Street',
  city: 'London',
  country: 'UK',
  postcode: 'SW1A 1AA'
)

CorrespondenceAddress.create!(
  person: applicant,
  address_line_one: '2 Mailing Street',
  city: 'London',
  country: 'UK',
  postcode: 'SW1A 2BB'
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
# Case + charge
# -----------------------------------------------------------------------------

kase = Case.create!(
  crime_application: app,
  case_type: CaseType::EITHER_WAY.to_s,
  hearing_court_name: 'Croydon Crown Court',
  hearing_date: Date.today + 7,
  is_first_court_hearing: 'yes',
  has_case_concluded: 'no',
  is_client_remanded: 'no',
  has_codefendants: 'no',
  client_other_charge_in_progress: 'no',
  )

charge = kase.charges.create!(offence_name: 'Common assault')
charge.offence_dates.first.update!(
  date_from: Date.today - 7,
  date_to: Date.today - 7
)

Passporting::IojPassporter.new(app).call
Passporting::MeansPassporter.new(app).call

# -----------------------------------------------------------------------------
# IOJ
# -----------------------------------------------------------------------------

Ioj.create!(
  case: kase,
  types: ['loss_of_liberty'],
  loss_of_liberty_justification: 'Risk of immediate custody if convicted'
)

# -----------------------------------------------------------------------------
# Partner details has nino
# -----------------------------------------------------------------------------

PartnerDetail.create!(
  crime_application: app,
  has_partner: 'yes',
  relationship_status: ClientRelationshipStatusType::NOT_SAYING,
  relationship_to_partner: RelationshipToPartnerType::NOT_SAYING,
  involvement_in_case: 'none',
  conflict_of_interest: 'no',
  has_same_address_as_client: 'yes',
  )

Partner.create!(
  crime_application: app,
  first_name: 'Alex',
  last_name: 'Partner',
  date_of_birth: Date.new(1991, 6, 15),
  benefit_type: 'none',
  has_nino: 'yes',
  nino: 'JW123444C',
  )

# -----------------------------------------------------------------------------
# Income (high level)
# -----------------------------------------------------------------------------

Income.create!(
  crime_application: app,
  income_above_threshold: 'yes',
  employment_status: ['employed'],
  partner_employment_status: ['not_working'],
  client_has_dependants: 'no',
  client_in_armed_forces: 'no',
  has_no_income_payments: 'yes',
  has_no_income_benefits: 'yes',
  partner_has_no_income_payments: 'yes',
  partner_has_no_income_benefits: 'yes',
  applicant_other_work_benefit_received: 'no',
  applicant_self_assessment_tax_bill: 'no'
)

# Employment model (legacy employment record)

employment = Employment.create!(
  crime_application: app,
  ownership_type: 'applicant',
  employer_name: 'Mr Employer',
  job_title: 'Manager',
  amount: 500_00,
  frequency: 'week',
  before_or_after_tax: { value: 'before_tax' },
  has_no_deductions: 'no',
  address: {
    address_line_one: '1 Work Road',
    address_line_two: 'Suite 2',
    city: 'London',
    country: 'UK',
    postcode: 'SW1A 3CC'
  }.as_json
)

Deduction.create!(
  employment: employment,
  deduction_type: 'income_tax',
  amount: 50_00,
  frequency: 'week'
)

# -----------------------------------------------------------------------------
# Outgoings (required for full means assessment)
# -----------------------------------------------------------------------------

Outgoings.create!(
  crime_application: app,
  housing_payment_type: 'rent',
  pays_council_tax: 'no',
  income_tax_rate_above_threshold: 'no',
  partner_income_tax_rate_above_threshold: 'no',
  has_no_other_outgoings: 'yes',
  outgoings_more_than_income: 'no'
)

OutgoingsPayment.create!(
  crime_application: app,
  payment_type: 'rent',
  amount: 80_000,
  frequency: 'month'
)

# -----------------------------------------------------------------------------
# Capital (required for full means assessment with either_way case type)
# -----------------------------------------------------------------------------

Capital.create!(
  crime_application: app,
  has_premium_bonds: 'no',
  partner_has_premium_bonds: 'no',
  has_no_savings: 'yes',
  has_no_investments: 'yes',
  has_national_savings_certificates: 'no',
  will_benefit_from_trust_fund: 'no',
  partner_will_benefit_from_trust_fund: 'no',
  has_no_properties: 'yes',
  has_frozen_income_or_assets: 'no',
  has_no_other_assets: 'yes'
)

# -----------------------------------------------------------------------------
# Supporting evidence
# -----------------------------------------------------------------------------

Document.create!(
  crime_application: app,
  filename: 'evidence.pdf',
  content_type: 'application/pdf',
  declared_content_type: 'application/pdf',
  file_size: 100.kilobytes,
  s3_object_key: "documents/#{app.id}/evidence.pdf",
  scan_status: 'pass',
  submitted_at: nil,
  annotations: {}
)

# -----------------------------------------------------------------------------
# Additional information
# -----------------------------------------------------------------------------

app.update!(
  additional_information_required: 'yes',
  additional_information: 'Client has provided further clarification about employment history.'
)

# -----------------------------------------------------------------------------
# Review form context (no persistence required beyond validation)
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
  legal_rep_has_partner_declaration: YesNoAnswer::YES,
)

# -----------------------------------------------------------------------------
# Declaration
# -----------------------------------------------------------------------------

Steps::Submission::DeclarationForm.new(
  crime_application: app,
  record: provider,
  legal_rep_has_partner_declaration: YesNoAnswer::YES,
  legal_rep_first_name: 'Test',
  legal_rep_last_name: 'Rep',
  legal_rep_telephone: '1234567890'
).save!

puts "Seeded crime application id=#{app.id} usn=#{app.usn}"
puts "Seeded applicant=#{applicant.first_name} #{applicant.last_name}"
