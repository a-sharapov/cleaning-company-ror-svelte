class Review
  include Mongoid::Document
  include Mongoid::Timestamps
  
  belongs_to :company_profile

  field :customer, type: String, default: "Anonymous"
  field :company_name, type: String
  field :description, type: String
  field :assessment, type: Integer, default: 5
  field :assets, type: Object
  field :slug, type: String, default: ->{ SecureRandom.uuid.to_s }

  validates :description, presence: true
  validates :company_name, presence: true
  validates :assessment, presence: true
  validates :slug, uniqueness: true
end
