class ApplicationPurger
  attr_reader :crime_application, :log_context, :current_provider

  def self.call(crime_application, log_context, current_provider = nil)
    new(crime_application, log_context, current_provider).call
  end

  def initialize(crime_application, log_context, current_provider = nil)
    @crime_application = crime_application
    @log_context = log_context
    @current_provider = current_provider
  end
  private_class_method :new

  def call
    ActiveRecord::Base.transaction do
      delete_orphan_stored_documents
      log_deletion
      crime_application.destroy!
    end
  end

  private

  def delete_orphan_stored_documents
    orphan_documents.each do |document|
      Datastore::Documents::Delete.new(document:, log_context:, current_provider:).call
    end
  end

  def orphan_documents
    crime_application.documents.stored.not_submitted
  end

  def log_deletion
    DeletionEntry.create!(
      record_id: crime_application.id,
      record_type: RecordType::APPLICATION.to_s,
      business_reference: crime_application.reference,
      deleted_by: current_provider ? current_provider.id : 'system_automated',
      reason: current_provider ? DeletionReason::PROVIDER_ACTION.to_s : DeletionReason::RETENTION_RULE.to_s
    )
  end
end
