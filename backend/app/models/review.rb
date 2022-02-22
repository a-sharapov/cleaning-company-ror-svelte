class Review
  include Mongoid::Document
  include Mongoid::Timestamps
  
  belongs_to :company_profile

  field :customer, type: String, default: "Anonymous"
  field :company_name, type: String
  field :description, type: String
  field :assessment, type: Integer, default: 5
  field :assets, type: Object

  validates :description, presence: true
  validates :company_name, presence: true
  validates :assessment, presence: true
end
