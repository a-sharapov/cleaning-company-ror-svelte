class Review
  include Mongoid::Document
  belongs_to :company_profile

  field :customer, type: String, default: "Anonymous"
  field :company_name, type: String
  field :description, type: String
  field :assessment, type: Integer, default: 5
  filed :assets, type: Object
  field :created_at, type: DateTime

  validates :description, presence: true
  validates :company_name, presence: true
  validates :assessment, presence: true
  
  def prepare_data
    self.created_at = Time.now
  end
end
