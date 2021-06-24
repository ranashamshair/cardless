class AddLegalDocType < ActiveRecord::Migration[6.1]
  def change
    add_column :companies, :legal_doc_type, :string
  end
end
