class ApplicationPurger
  attr_reader :crime_application, :current_provider, :log_context

  def self.call(crime_application, current_provider, log_context)
    new(crime_application, current_provider, log_context).call
  end

  def initialize(crime_application, current_provider, log_context)
    @crime_application = crime_application
    @current_provider = current_provider
    @log_context = log_context
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
      Datastore::Documents::Delete.new(document:, log_context:).call
    end
  end

  def orphan_documents
    crime_application.documents.stored.not_submitted
  end

  def log_deletion
    DeletionLog.create!(
      record_id: crime_application.id,
      record_type: RecordType::APPLICATION.to_s,
      business_reference: crime_application.reference,
      deleted_by: current_provider.id,
      reason: DeletionReason::MANUAL.to_s
    )
  end
end
