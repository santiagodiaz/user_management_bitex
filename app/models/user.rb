class User < ApplicationRecord
  mount_base64_uploader :id_card_image, ImageUploader
  mount_base64_uploader :proof_of_address, ImageUploader

  validates_presence_of :first_name, :last_name, :birth_date, :gender, :nationality, :id_number,
                        :id_card_image, :country, :city, :street_address, :street_number,
                        :floor, :postal_code, :proof_of_address

end
