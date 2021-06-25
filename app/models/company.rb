class Company < ApplicationRecord
  belongs_to :user

  enum business_type: { 'limited_company' => 'limited_company', 'charity' => 'charity', 'individual' => 'individual',
                        'partnership' => 'partnership', 'trust' => 'trust' }

  enum industry: {'agriculter_service'=>'Agriculture Service','it_service'=> 'IT Services','health_care' => 'Health Care','utilities' => 'Utilities'}

  has_one_attached :logo
  has_one_attached :id_doc
  has_one_attached :legal_doc

  validates :logo, content_type: [:png, :jpg, :jpeg]
  validates :id_doc, content_type: [:png, :jpg, :jpeg, :pdf]
  validates :legal_doc, content_type: [:png, :jpg, :jpeg, :pdf]

  def country_name
    country = ISO3166::Country[self.country]
    if country.present?
      country.translations[I18n.locale.to_s] || country.name
    else
      self.country
    end
  end
end
