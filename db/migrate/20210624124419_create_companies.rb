class CreateCompanies < ActiveRecord::Migration[6.1]
  def change
    create_table :companies do |t|
      t.integer :user_id
      t.string :address
      t.string :country
      t.string :city
      t.string :postcode
      t.string :logo
      t.string :business_type
      t.string :industry
      t.string :buisness_work
      t.string :name
      t.string :vat
      t.string :website
      t.string :support_email
      t.string :phone
      t.string :legal_doc
      t.string :id_doc

      t.timestamps
    end
  end
end
