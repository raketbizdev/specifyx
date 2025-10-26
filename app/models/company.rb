# app/models/company.rb
class Company < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  belongs_to :user                           # owner
  has_many   :jobs, dependent: :restrict_with_error

  # Validations
  validates :name, presence: true, length: { maximum: 140 }
  validates :website,
            allow_blank: true,
            format: { with: /\Ahttps?:\/\/[\w.-]+(?:\.[\w\.-]+)+[\S]*\z/i,
                      message: "must start with http:// or https://" }

  # Scopes
  scope :owned_by, ->(user) { where(user_id: user.id) }

  # Helpers
  def owner?(u) = u&.admin? || user_id == u&.id

  def should_generate_new_friendly_id?
    slug.blank? || will_save_change_to_name?
  end
end
