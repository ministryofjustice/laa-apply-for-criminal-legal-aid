class ApplicationPurger
  attr_reader :crime_application, :current_provider, :request_ip

  def self.call(crime_application, current_provider, request_ip)
    new(crime_application, current_provider, request_ip).call
  end

  def initialize(crime_application, current_provider, request_ip)
    @crime_application = crime_application
    @current_provider = current_provider
    @request_ip = request_ip
  end
  private_class_method :new

  def call
    delete_orphan_stored_documents
    crime_application.destroy!
  end

  private

  def delete_orphan_stored_documents
    orphan_documents.each do |document|
      Datastore::Documents::Delete.new(document:, current_provider:, request_ip:).call
    end
  end

  def orphan_documents
    crime_application.documents.stored.not_submitted
  end
end
