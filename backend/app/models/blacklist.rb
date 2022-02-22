class Blacklist
  include Mongoid::Document
  include Mongoid::Timestamps
  
  belongs_to :user

  field :description, type: String

  validates :description, presence: true
end
