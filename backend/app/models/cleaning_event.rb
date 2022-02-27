class CleaningEvent
  include Mongoid::Document
  include Mongoid::Timestamps
  
  belongs_to :company_profile
  has_many :attachments, dependent: :destroy, validate: false

  field :customer, type: String, default: "Anonymous"
  field :type, type: String
  field :address, type: Object
  field :description, type: String
  field :status, type: String, default: "new"
  field :schedule, type: String
  field :services, type: Array
  field :is_regular, type: Boolean, default: false
  field :planed_at, type: DateTime
  field :assets, type: Object
  field :slug, type: String, default: ->{ SecureRandom.uuid.to_s }

  validates :company_name, presence: true
  validates :type, inclusion: {in: %w(new confirmed canceled), message: "Type of event should be new, confirmed or canceled"}
  validates :address, presence: true
  validates :schedule, presence: true
  validates :services, presence: true
  validates :is_regular, presence: true
  validates :planed_at, presence: true
  validates :slug, uniqueness: true
end