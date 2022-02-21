class Blacklist
  include Mongoid::Document
  embedded_in :user
  
  before_save :prepare_data

  field :description, type: String
  field :created_at, type: DateTime
  field :banned_until, type: DateTime

  validates :description, presence: true
  validates :banned_until, presence: true

  def prepare_data
    self.description = description.normalize.to_s unless description.blank?
    self.created_at = Time.now
  end
end
