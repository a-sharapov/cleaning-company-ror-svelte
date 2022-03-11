class User
  include Mongoid::Document
  include Mongoid::Paperclip
  include Mongoid::Timestamps
  include ActiveModel::SecurePassword

  has_one :blacklist
  has_one :company_profile, dependent: :destroy
  
  before_save :prepare_data

  field :login, type: String
  field :role, type: String, default: "client"
  field :description, type: String
  field :email, type: String
  field :phone, type: String
  field :address, type: Object, default: {}
  field :password_digest, type: String
  field :tokens, type: Array
  field :confirmed, type: Boolean, default: false
  field :blocked_until, type: DateTime
  field :wrong_attempts_count, type: Integer, default: 0
  field :banned, type: Boolean, default: false
  field :activation_code, type: String

  validates :login,     presence: true, 
                        uniqueness: true, 
                        length: {minimum: 6}, 
                        format: { without: /\s/, message: " не должен содержать пробелов" }

  validates :password,  presence: true, 
                        length: {minimum: 8, maximum: 72}, 
                        format: {with: /\A(?=.{8,})(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[[:^alnum:]])/x, message: " должен иметь хотя бы одну цифру, спецзнак и символ в верхнем регистре"},
                        if: :password_present? || changes[:password_digest]

  validates :role,      inclusion: {in: %w(client company), message: "Тип пользователя может быть только клиент и компания"}

  validates :email,     presence: false, 
                        uniqueness: true, 
                        length: {minimum: 8, maximum: 72}, 
                        format: {with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, message: " должен соответсвовать шаблону name@domain.zone"}, 
                        if: :email_present?

  validates :phone,     uniqueness: true, 
                        numericality: true, 
                        length: {minimum: 10, maximum: 15}, 
                        presence: {message: " должен сотоять исключительно из цифр"}, 
                        if: :phone_present?

  validate :mail_and_phone_unpresent?
  
  has_secure_password
  has_mongoid_attached_file :avatar
  validates_attachment :avatar, content_type: { content_type: ["image/jpg", "image/jpeg", "image/png", "image/gif"] }
  
  private
  def password_present?
    !password.nil? && self.password_digest.present?
  end

  def phone_present?
    !phone.nil?
  end

  def email_present?
    !email.nil?
  end

  def mail_and_phone_unpresent?
    if email.nil? && phone.nil?
      errors.add(:email, " или Телефон должен быть указан обязательно")
    end
  end

  def prepare_data
    self.email = email.downcase unless email.blank?
    self.phone = phone.gsub(/[+-]/, '') unless phone.blank?
    self.blocked_until = Time.now
  end
end