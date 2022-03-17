class CompanyProfile
  include Mongoid::Document
  include Mongoid::Paperclip
  include Mongoid::Timestamps
  include Mongoid::Search
  
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
  validates :slug, uniqueness: true, 
                    length: {minimum: 3}, 
                    format: { without: /\s/, message: " не должен содержать пробелов" }

  has_mongoid_attached_file :logotype
  validates_attachment :logotype, content_type: { content_type: ["image/jpg", "image/jpeg", "image/png", "image/gif"] }

  search_in :slug, :company_name
end
