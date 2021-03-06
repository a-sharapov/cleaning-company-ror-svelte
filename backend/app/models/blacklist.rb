class Blacklist
  include Mongoid::Document
  include Mongoid::Timestamps
  
  belongs_to :user

  field :description, type: String
  field :login, type: String

  validates :login, presence: true, uniqueness: true
  validates :description, presence: true
end
