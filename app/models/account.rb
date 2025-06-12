class Account < ApplicationRecord
  enum :status, { pending: 0, active: 1, suspended: 2, cancelled: 3 }

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :plan_id, presence: true
  validates :identifier, presence: true, uniqueness: true
  validates :invitation_token, presence: true, uniqueness: true, on: :create
  validates :status, presence: true, inclusion: { in: statuses.keys }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP, message: "must be a valid email address" }
  validate :validate_identifier

  before_validation :set_default_status, on: :create

  belongs_to :plan

  # Validates that the identifier is a valid CNPJ or CPF
  def validate_identifier
    unless CNPJ.valid?(identifier) || CPF.valid?(identifier)
      errors.add(:identifier, "must be a valid CNPJ or CPF")
    end
  end

  # Generates a unique invitation token for the account
  def generate_invitation_token
    self.invitation_token = SecureRandom.hex(10)
  end

  # Sets the plan expiration date to one month
  def set_plan_expires_at
    self.plan_expires_at = 1.month.from_now
  end

  # Sets the default status to pending if not already set
  def set_default_status
    self.status = :pending
  end
end
