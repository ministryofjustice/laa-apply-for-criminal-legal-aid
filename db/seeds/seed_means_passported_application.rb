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
# Applicant – benefit_check_result: true triggers MeansPassporter passporting
# -----------------------------------------------------------------------------

applicant = Applicant.create!(
  crime_application: app,
  first_name: 'Benefit Passported',
  last_name: 'Applicant',
  date_of_birth: Date.new(1990, 1, 1),
  telephone_number: '07000000000',
  correspondence_address_type: CorrespondenceType::HOME_ADDRESS,
  preferred_correspondence_language: 'english',
  has_nino: 'yes',
  nino: 'JW123456C',
  residence_type: 'rented',
  benefit_type: 'universal_credit',
  benefit_check_result: true
)

HomeAddress.create!(
  person: applicant,
  address_line_one: '1 High Street',
  city: 'London',
  country: 'UK',
  postcode: 'SW1A 1AA'
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
  case_type: CaseType::SUMMARY_ONLY.to_s,
  hearing_court_name: 'Croydon Crown Court',
  hearing_date: Date.today + 7,
  is_first_court_hearing: 'yes',
  has_case_concluded: 'no',
  is_client_remanded: 'no',
  has_codefendants: 'no',
)

charge = kase.charges.create!(offence_name: 'Common assault')
charge.offence_dates.first.update!(
  date_from: Date.today - 7,
  date_to: Date.today - 7
)

Passporting::IojPassporter.new(app).call
Passporting::MeansPassporter.new(app).call

# -----------------------------------------------------------------------------
# IOJ – adult applicant is not IOJ-passported; justification required
# -----------------------------------------------------------------------------

Ioj.create!(
  case: kase,
  types: ['loss_of_liberty'],
  loss_of_liberty_justification: 'Risk of immediate custody if convicted'
)

# -----------------------------------------------------------------------------
# Partner – no partner; relationship_status required for client_details section
# -----------------------------------------------------------------------------

PartnerDetail.create!(
  crime_application: app,
  has_partner: 'no',
  relationship_status: ClientRelationshipStatusType::SINGLE.to_s,
)

# -----------------------------------------------------------------------------
# More information – no additional information required
# -----------------------------------------------------------------------------

Steps::Submission::MoreInformationForm.new(
  crime_application: app,
  additional_information_required: 'no'
).save!

# -----------------------------------------------------------------------------
# Review form (no income/capital/outgoings – means passported)
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
