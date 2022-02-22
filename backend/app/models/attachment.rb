class Attachment
  include Mongoid::Document
  include Mongoid::Paperclip
  include Mongoid::Timestamps

  belongs_to :cleaning_event

  has_mongoid_attached_file :attachment, disable_fingerprint: true
end