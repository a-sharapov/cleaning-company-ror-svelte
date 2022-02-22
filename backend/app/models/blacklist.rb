class Blacklist
  include Mongoid::Document
  include Mongoid::Timestamps
  
  belongs_to :user

  field :login, type: String
  field :description, type: String

  validates :login, presence: true
  validates :description, presence: true
end
