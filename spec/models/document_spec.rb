require 'rails_helper'

RSpec.describe Document, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should have_many(:activities).dependent(:destroy) }
  end

  describe 'validations' do
    # Add any validations if present in the model
  end

  describe 'constants' do
    it 'has TOURIST constant with required documents' do
      expect(Document::TOURIST).to eq([
        "Home country driving license and IDP",
        "Passport Copy",
        "Copy of visa Entry Stamp"
      ])
    end

    it 'has RESIDENT constant with required documents' do
      expect(Document::RESIDENT).to eq([
        "A Valid UAE driving license",
        "Emirates ID front and back"
      ])
    end

    it 'has DOC_FIELDS constant with field mappings' do
      expect(Document::DOC_FIELDS).to be_a(Hash)
      expect(Document::DOC_FIELDS['uae_license']).to eq(['A Valid UAE driving license', 'uae_license'])
      expect(Document::DOC_FIELDS['emirates_id']).to eq(['Emirates ID front and back', 'emirates_id'])
    end
  end

  describe 'callbacks' do
    describe 'after_update' do
      context 'when status changes' do
        it 'calls update_user_bookings_status' do
          user = create(:user, :resident)
          document = user.documents.first
          expect(document).to receive(:update_user_bookings_status)
          document.update(status: 'approved')
        end

        it 'calls log_document_status_change' do
          user = create(:user, :resident)
          document = user.documents.first

          expect {
            document.update(status: 'approved')
          }.to change(Activity, :count).by(1)

          activity = Activity.last
          expect(activity.action).to eq('document_approved')
        end

        it 'does not call callbacks when status does not change' do
          user = create(:user, :resident)
          document = user.documents.first
          document.update(status: 'pending')

          expect {
            document.update(doc_name: 'New Name')
          }.not_to change(Activity, :count)
        end
      end
    end

    describe 'update_user_bookings_status' do
      context 'when all documents are approved' do
        it 'updates pending bookings to confirmed' do
          user = create(:user, :resident)
          document = user.documents.first
          user.documents.update_all(status: 'approved')
          booking = create(:booking, user: user, status: 'pending')

          document.update(status: 'pending')
          document.update(status: 'approved')

          expect(booking.reload.status).to eq('confirmed')
        end
      end

      context 'when a document is rejected' do
        it 'updates confirmed bookings to pending' do
          user = create(:user, :resident)
          document = user.documents.first
          user.documents.update_all(status: 'approved')
          booking = create(:booking, user: user, status: 'confirmed')

          document.update(status: 'rejected')

          expect(booking.reload.status).to eq('pending')
        end
      end
    end

    describe 'log_document_status_change' do
      it 'creates an activity log when status changes' do
        user = create(:user, :resident)
        document = user.documents.first

        expect {
          document.update(status: 'approved')
        }.to change(Activity, :count).by(1)

        activity = Activity.last
        expect(activity.user).to eq(user)
        expect(activity.subject).to eq(document)
        expect(activity.action).to eq('document_approved')
        expect(activity.description).to include(document.doc_name)
      end

      it 'includes metadata with status change information' do
        user = create(:user, :resident)
        document = user.documents.first
        document.update(status: 'pending')
        document.update(status: 'rejected')

        activity = Activity.last
        metadata = activity.metadata_hash
        expect(metadata['previous_status']).to eq('pending')
        expect(metadata['new_status']).to eq('rejected')
      end
    end
  end

  describe 'class methods' do
    describe '.doc_info_for_field' do
      it 'returns document info for valid field' do
        result = Document.doc_info_for_field('uae_license')
        expect(result).to eq(['A Valid UAE driving license', 'uae_license'])
      end

      it 'returns nil for invalid field' do
        result = Document.doc_info_for_field('invalid_field')
        expect(result).to be_nil
      end

      it 'returns correct info for all defined fields' do
        Document::DOC_FIELDS.each do |field, info|
          expect(Document.doc_info_for_field(field)).to eq(info)
        end
      end
    end
  end

  describe 'instance methods' do
    describe '#all_documents_approved?' do
      context 'for resident user' do
        let(:user) { create(:user, :resident) }

        it 'returns true when all required documents are approved' do
          user.documents.each do |doc|
            doc.update(status: 'approved')
          end

          document = user.documents.first
          expect(document.send(:all_documents_approved?)).to be true
        end

        it 'returns false when some documents are missing' do
          user.documents.destroy_all
          document = create(:document, user: user, doc_name: Document::RESIDENT.first)

          expect(document.send(:all_documents_approved?)).to be false
        end

        it 'returns false when some documents are not approved' do
          document = user.documents.first
          document.update(status: 'pending')

          expect(document.send(:all_documents_approved?)).to be false
        end
      end

      context 'for tourist user' do
        let(:user) { create(:user, :tourist) }

        it 'returns true when all required documents are approved' do
          user.documents.each do |doc|
            doc.update(status: 'approved')
          end

          document = user.documents.first
          expect(document.send(:all_documents_approved?)).to be true
        end

        it 'checks tourist specific documents' do
          user.documents.destroy_all
          Document::TOURIST.each do |doc_name|
            create(:document, user: user, doc_name: doc_name, status: 'approved')
          end

          document = user.documents.reload.first
          expect(document.send(:all_documents_approved?)).to be true
        end
      end
    end
  end

  describe 'Active Storage attachments' do
    it 'has many_attached images' do
      document = create(:document, user: create(:user))
      expect(document).to respond_to(:images)
    end
  end
end
