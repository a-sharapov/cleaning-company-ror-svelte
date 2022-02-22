class Assets
  include Mongoid::Document
  include Mongoid::Timestamps

  field :type, type: String
  field :content, type: Object
  field :url, type: String, default: ->{ type.parameterize }

  validates :type, presence: true
  validates :content, presence: true
end