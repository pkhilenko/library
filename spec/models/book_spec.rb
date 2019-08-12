require 'rails_helper'

RSpec.describe Book, type: :model do
  let(:book) { create(:book) }

  describe 'associations' do
    subject { book }

    it { should have_many(:book_copies) }
    it { should belong_to(:author) }
  end

  describe 'validations' do
    subject { book }

    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:author) }
  end
end
