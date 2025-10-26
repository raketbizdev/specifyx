# app/models/job_application.rb
class JobApplication < ApplicationRecord
  belongs_to :user        # applicant
  belongs_to :job
  has_one    :company, through: :job

  enum status: {
    submitted:     0,
    under_review:  1,
    shortlisted:   2,
    rejected:      3,
    hired:         4
  }, _default: :submitted

  validates :cover_letter, presence: true
  validates :user_id, uniqueness: { scope: :job_id, message: "has already applied to this job" }
  validate  :applicant_cannot_be_owner

  scope :for_owner, ->(owner) { joins(job: :company).where(companies: { user_id: owner.id }) }
  scope :recent,    -> { order(created_at: :desc) }

  private

  def applicant_cannot_be_owner
    return if job.blank?
    errors.add(:base, "You cannot apply to your own job posting.") if job.company.user_id == user_id
  end
end
