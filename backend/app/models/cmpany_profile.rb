class CompanyProfile
  include Mongoid::Document
  embedded_in :user
  has_many :review, validate: false
  has_many :cleaning_event, validate: false

  before_save :prepare_data

  field :logotype, type: String
  field :company_name, type: String
  field :description, type: String
  field :address, type: Object
  field :service_types, type: Array
  field :prices, type: Object

  validates :company_name, presence: true
  validates :address, presence: true
  validates :service_types, presence: true
  validates :prices, presence: true

  def prepare_data
    self.description = description.normalize.to_s unless description.blank?
  end
end