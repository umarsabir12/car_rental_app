class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :bookings, dependent: :destroy
  has_many :documents
  after_create :create_documents

  def full_name
    "#{self.first_name} #{self.last_name}"
  end

  def booking_alert
    required_docs = nationality == "resident" ? Document::RESIDENT : Document::TOURIST
    user_docs = documents.where(doc_name: required_docs)
    statuses = user_docs.pluck(:status)
    statuses.size < required_docs.size || statuses.include?("reject")
  end


  def has_required_pending_document?
    doc_names = nationality == "resident" ? Document::RESIDENT : Document::TOURIST
    documents.where(user_id: self.id, doc_name: doc_names, status: "pending").exists?
  end

  def create_documents
    doc_names = nationality == "resident" ? Document::RESIDENT : Document::TOURIST
    doc_names.each do |doc_name|
      documents.create!(doc_name: doc_name, document_type: self.nationality == 'resident' ? 'Resident' : 'Tourist', status: 'not uploaded')
    end
  end

  def document_alert_message
    docs = documents.to_a
    if docs.any? { |d| d.status == 'not uploaded' }
      'Please submit all required documents to proceed with your payment and complete the booking process.'
    elsif docs.any? { |d| d.status == 'pending' }
      'Your documents are in review. Once they are approved, you are good to go with the payment.'
    else
      nil
    end
  end

end
