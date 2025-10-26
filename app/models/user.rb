# app/models/user.rb
class User < ApplicationRecord
  # Devise
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable,
         :lockable, :timeoutable, :trackable

  # Roles
  enum role: { user: 0, admin: 1 }

  # Associations
  has_one  :profile, dependent: :destroy
  has_many :companies, dependent: :destroy
  has_many :jobs, through: :companies               # <-- Jobs now via Company
  has_many :job_applications, dependent: :destroy

  # Auto-provision basics
  after_commit :ensure_profile!, on: :create
  after_commit :ensure_default_company!, on: :create

  private

  def ensure_profile!
    return if profile.present?

    handle = email.to_s.split("@").first
    create_profile!(
      first_name: handle&.titleize,
      display_name: handle,
      public: false
    )
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error("[User##{id}] Profile auto-create failed: #{e.message}")
  end

  def ensure_default_company!
    return if companies.exists?

    base =
      profile&.display_name.presence ||
      profile&.full_name.presence    ||
      email.to_s.split("@").first&.titleize ||
      "Company #{id}"

    companies.create!(name: base)
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error("[User##{id}] Company auto-create failed: #{e.message}")
  end
end
