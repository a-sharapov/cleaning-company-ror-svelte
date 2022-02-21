class CompanyProfile
  include Mongoid::Document
  belongs_to :user
  has_many :reviews, dependent: :destroy, foreign_key: "company_name", class_name: "Review"
  has_many :events, foreign_key: "company_name", class_name: "Event"

  before_save :prepare_data

  field :login, type: String
  field :logotype, type: String
  field :company_name, type: String
  field :description, type: String
  field :address, type: Object
  field :service_types, type: Array
  field :prices, type: Object

  validates :login, presence: true
  validates :company_name, presence: true
  validates :address, presence: true
  validates :service_types, presence: true
  validates :prices, presence: true

  def prepare_data
    self.description = description.normalize.to_s unless description.blank?
  end
end
