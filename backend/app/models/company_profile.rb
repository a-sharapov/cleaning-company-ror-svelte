class CompanyProfile
  include Mongoid::Document
  include Mongoid::Paperclip
  include Mongoid::Timestamps
  
  belongs_to :user
  has_many :review, validate: false
  has_many :cleaning_event, validate: false

  field :company_name, type: String
  field :description, type: String
  field :address, type: Object
  field :service_types, type: Array, default: []
  field :prices, type: Object, default: {}
  field :slug, type: String, default: ->{ Translit.convert(self.company_name, :english).parameterize }

  validates :company_name, presence: true
  validates :address, presence: true
  validates :slug, uniqueness: true

  has_mongoid_attached_file :logotype
end
