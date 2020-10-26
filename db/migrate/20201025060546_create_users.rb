class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.date   :birth_date
      t.string :gender
      t.string :nationality
      t.string :id_number
      t.string :id_card_image
      t.string :city
      t.string :country
      t.string :floor
      t.string :postal_code
      t.string :street_address
      t.string :street_number
      t.string :proof_of_address
      t.string :issue_id
      t.string :issue_status

      t.timestamps
    end
  end
end
