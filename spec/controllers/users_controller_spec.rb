require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  before(:each) do
    @id_card_file = fixture_file_upload("spec/fixtures/files/id_card_example.jpeg", "image/jpeg")
    @proof_of_address_file = fixture_file_upload("spec/fixtures/files/proof_of_address.jpg", "image/jpg")
  end

  describe 'POST create' do
    it 'successfully creates a new user' do

      user_params = {
        "user": {
          "first_name": "testuser",
          "last_name": "Doe",
          "birth_date": "1990-02-19",
          "nationality": "AR",
          "gender": "female",
          "id_number": "123",
          "id_card_image": @id_card_file,
          "country": "AR",
          "city": "CABA",
          "street_address": "Mitre",
          "street_number": "1900",
          "postal_code": "1030",
          "floor": "0",
          "proof_of_address": @proof_of_address_file
        }
      }
      expect{
          post :create, params: user_params
        }.to change(User,:count).by(1)
    end
  end

  describe 'create' do
    it 'successfully creates a new user' do
      user = User.create(first_name: "testuser", last_name: "Doe", nationality: "AR",
                         gender: "male", birth_date: "1970-02-20", id_number: "123",
                         id_card_image: File.open(File.join(Rails.root, '/spec/fixtures/files/id_card_example.jpeg')),
                         country: "AR", city: "CABA", street_address: "Mitre",
                         street_number: "1080", floor: "0", postal_code: "1030",
                         proof_of_address: File.open(File.join(Rails.root, '/spec/fixtures/files/proof_of_address.jpg')))

      expect(User.last.last_name).to eq("Doe")

    end

    it 'fails creating a new user' do
      @user = User.new(first_name: "testuser", last_name: "Doe", nationality: "AR",
                       gender: "male", birth_date: "1970-02-20", id_number: "123",
                       id_card_image: File.open(File.join(Rails.root, '/spec/fixtures/files/id_card_example.jpeg')),
                       country: "AR", city: "CABA", street_address: "Mitre",
                       street_number: "1080", floor: "0")
      expect { @user.save! }.to  raise_error(ActiveRecord::RecordInvalid,"Validation failed: Postal code can't be blank, Proof of address can't be blank")
    end
  end
end
