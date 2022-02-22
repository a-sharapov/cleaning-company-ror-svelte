class CleaningEvent
  include Mongoid::Document
  include Mongoid::Timestamps
  
  belongs_to :company_profile
  belongs_to :user
  has_many :attachments

  field :event_code, type: String
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

  validates :company_name, presence: true
  validates :type, inclusion: {in: %w(new confirmed canceled), message: "Type of event should be new, confirmed or canceled"}
  validates :address, presence: true
  validates :schedule, presence: true
  validates :services, presence: true
  validates :is_regular, presence: true
  validates :planed_at, presence: true
end