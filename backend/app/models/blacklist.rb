class Blacklist
  include Mongoid::Document
  belongs_to :user
  
  before_save :prepare_data

  field :login, type: String
  field :description, type: String
  field :created_at, type: DateTime

  validates :login, presence: true
  validates :description, presence: true

  def prepare_data
    self.created_at = Time.now
  end
end
