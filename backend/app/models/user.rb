class User
  include Mongoid::Document
  include ActiveModel::SecurePassword

  before_save :prepare_data

  field :login, type: String
  field :role, type: String
  field :description, type: String
  field :email, type: String
  field :phone, type: String
  field :address, type: Object
  field :password_digest, type: String
  field :tokens, type: Array
  field :confirmed, type: Boolean

  validates :login,     presence: true, 
                        uniqueness: true, 
                        length: {minimum: 6}, 
                        format: { without: /\s/, message: "Login must not contains any spaces" }

  validates :password,  presence: true, 
                        length: {minimum: 8, maximum: 72}, 
                        format: {with: /\A(?=.{8,})(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[[:^alnum:]])/x, message: "Password must contain at least one digit, one character, one alphabetic character"},
                        if: :password_not_present? || changes[:password_digest]

  validates :role,      inclusion: {in: %w(client company), message: "User only must be a client or company"}

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
  end
end
