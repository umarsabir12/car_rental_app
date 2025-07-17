class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :bookings, dependent: :destroy
  has_many :documents

  def full_name
    "#{self.first_name} #{self.last_name}"
  end

  def booking_alert
    required_docs = nationality == "local" ? Document::RESIDENT : Document::TOURIST
    user_docs = documents.where(doc_name: required_docs)
    statuses = user_docs.pluck(:status)
    statuses.size < required_docs.size || statuses.include?("reject")
  end


  def has_required_pending_document?
    doc_names = nationality == "local" ? Document::RESIDENT : Document::TOURIST
    documents.where(user_id: self.id, doc_name: doc_names, status: "pending").exists?
  end

end
