class User
  include Mongoid::Document
  include ActiveModel::SecurePassword
  has_one :blacklist, dependent: :destroy, foreign_key: "login", class_name: "Blacklist"
  has_one :company_profile, dependent: :destroy, foreign_key: "login", class_name: "CompanyProfile"
  has_many :reviews, foreign_key: "login", class_name: "Review"
  has_many :events, dependent: :destroy, foreign_key: "login", class_name: "Event"

  before_save :prepare_data

  field :login, type: String
  field :role, type: String, default: "client"
  field :description, type: String
  field :email, type: String
  field :phone, type: String
  field :address, type: Object
  field :password_digest, type: String
  field :tokens, type: Array
  field :confirmed, type: Boolean, default: false
  field :blocked_until, type: DateTime
  field :wrong_attempts_count, type: Integer, default: 0
  field :banned, type: Boolean, default: false
  field :activation_code, type: String
  field :created_at, type: DateTime
  field :updated_at, type: DateTime

  validates :login,     presence: true, 
                        uniqueness: true, 
                        length: {minimum: 6}, 
                        format: { without: /\s/, message: "Login must not contains any spaces" }

  validates :password,  presence: true, 
                        length: {minimum: 8, maximum: 72}, 
                        format: {with: /\A(?=.{8,})(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[[:^alnum:]])/x, message: "Password must contain at least one digit, one character, one alphabetic character"},
                        if: :password_not_present? || changes[:password_digest]

  validates :role,      inclusion: {in: %w(client company), message: "User should be a client or company"}

  validates :email,     presence: false, 
                        uniqueness: true, 
                        length: {minimum: 8, maximum: 72}, 
                        format: {with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, message: "Email must begin match with template name@domain.zone"}, 
                        if: :email_present?

  validates :phone,     presence: false, 
                        uniqueness: true, 
                        numericality: true, 
                        length: {minimum: 10, maximum: 15}, 
                        presence: {message: "Only positive number without spaces are allowed"}, 
                        if: :phone_present?

  validate :mail_and_phone_unpresent?

  has_secure_password

  private
  def password_not_present?
    password.nil? && !self.password_digest.present?
  end

  def phone_present?
    !phone.nil?
  end

  def email_present?
    !email.nil?
  end

  def mail_and_phone_unpresent?
    if email.nil? && phone.nil?
      errors.add(:email, "Email or Phone must be specified")
    end
  end

  def prepare_data
    self.email = email.downcase unless email.blank?
    self.description = description.normalize.to_s unless description.blank?
    self.blocked_until = Time.now
    if self.created_at.present?
      self.updated_at = Time.now
    else
      self.created_at = Time.now
    end
  end
end
