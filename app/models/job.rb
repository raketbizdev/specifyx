# app/models/job.rb
class Job < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :slugged

  belongs_to :company, inverse_of: :jobs
  has_one    :user, through: :company          # owner (via company)

  has_many :job_applications, dependent: :destroy

  validates :title, :description, presence: true

  # Convenience scopes
  scope :for_user,    ->(user) { joins(:company).where(companies: { user_id: user.id }) }
  scope :with_company, ->        { includes(:company) }

  # Helper: can this user manage the job?
  def owner?(u) = u&.admin? || company.user_id == u&.id

  # Regenerate slug when title changes
  def should_generate_new_friendly_id?
    slug.blank? || will_save_change_to_title?
  end
end
