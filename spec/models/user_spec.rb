require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'creation' do
    it 'can not be created without required params' do
      user = User.create(first_name: "testuser", last_name: "asdf", nationality: "AR")

      expect(user).to be_invalid
    end
    it 'can be created' do
      user = User.create(first_name: "testuser", last_name: "asdf", nationality: "AR",
                         gender: "male", birth_date: "1970-02-20", id_number: "123",
                         id_card_image: File.open(File.join(Rails.root, '/spec/fixtures/files/id_card_example.jpeg')),
                         country: "AR", city: "CABA", street_address: "Mitre",
                         street_number: "1080", floor: "0", postal_code: "1030",
                         proof_of_address: File.open(File.join(Rails.root, '/spec/fixtures/files/proof_of_address.jpg')))

      expect(user).to be_valid
    end
  end
end
