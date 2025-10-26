# app/models/profile.rb
class Profile < ApplicationRecord
  # -------------------------------------------------
  # Slug / vanity URL
  # We assume you still want pretty URLs. We'll prefer `public_handle`,
  # then `display_name`, then fallback to "user-<id>".
  # -------------------------------------------------
  extend FriendlyId
  friendly_id :slug_source, use: :slugged

  # -------------------------------------------------
  # Associations
  # -------------------------------------------------
  belongs_to :user

  has_many :experiences,    dependent: :destroy
  has_many :educations,     dependent: :destroy
  has_many :certifications, dependent: :destroy
  has_many :skills,         dependent: :destroy
  has_many :projects,       dependent: :destroy
  has_many :languages,      dependent: :destroy
  has_many :achievements,   dependent: :destroy

  accepts_nested_attributes_for :experiences,
                                allow_destroy: true,
                                reject_if: :all_blank

  # -------------------------------------------------
  # Validations
  # -------------------------------------------------

  # A user should only have one profile
  validates :user_id, uniqueness: true

  # Branding / identity
  validates :display_name,
            presence: true,
            length: { maximum: 100 }

  # Headline is like LinkedIn headline / elevator pitch
  validates :headline,
            length: { maximum: 200 },
            allow_blank: true

  # "About me" summary/blurb
  validates :summary,
            length: { maximum: 2000 },
            allow_blank: true

  # Handle that recruiters / public can see (vanity URL / slug-like)
  # We keep this separate from the FriendlyId slug because slug can change;
  # public_handle is an editable profile field.
  validates :public_handle,
            presence: true,
            uniqueness: true,
            length: { maximum: 100 },
            format: {
              with: /\A[a-z0-9\-]+\z/,
              message: "can only contain lowercase letters, numbers, and dashes"
            }

  # Visibility flags
  validates :is_public, inclusion: { in: [ true, false ] }
  validates :allow_contact, inclusion: { in: [ true, false ] }
  validates :show_fullname, inclusion: { in: [ true, false ] }

  # Work preferences
  validates :open_to_remote, inclusion: { in: [ true, false ] }
  validates :open_to_relocation, inclusion: { in: [ true, false ] }

  validates :availability_status,
            length: { maximum: 50 },
            allow_blank: true

  validates :seniority_level,
            length: { maximum: 50 },
            allow_blank: true

  # Location
  validates :location_city,
            length: { maximum: 100 },
            allow_blank: true
  validates :location_country,
            length: { maximum: 100 },
            allow_blank: true

  # Salary expectation
  validates :min_salary_expectation,
            numericality: {
              allow_nil: true,
              only_integer: true,
              greater_than_or_equal_to: 0
            }

  validates :salary_currency,
            length: { maximum: 10 },
            allow_blank: true

  # Links
  validates :website_url,
            :linkedin_url,
            :github_url,
            :portfolio_url,
            length: { maximum: 255 },
            allow_blank: true

  # Internal scoring / trust (user cannot edit directly, but can't be nil)
  validates :profile_completion_score,
            :match_strength_score,
            :reputation_score,
            numericality: {
              only_integer: true,
              greater_than_or_equal_to: 0
            },
            allow_nil: true

  validates :verified_identity, inclusion: { in: [ true, false ] }
  validates :verified_skills,   inclusion: { in: [ true, false ] }

  # -------------------------------------------------
  # Scopes for recruiter / search
  # -------------------------------------------------

  scope :recently_updated, -> {
    where("last_edited_at >= ?", 30.days.ago).order(last_edited_at: :desc)
  }

  scope :actively_looking, -> {
    where(availability_status: "Active")
  }

  scope :in_country, ->(country_code_or_name) {
    where(location_country: country_code_or_name)
  }

  scope :for_role, ->(role_name) {
    where("desired_role_primary ILIKE ? OR desired_role_secondary ILIKE ?",
          "%#{role_name}%", "%#{role_name}%")
  }

  # -------------------------------------------------
  # Callbacks
  # -------------------------------------------------

  before_validation :normalize_public_handle
  before_save :sync_last_active_timestamp

  # -------------------------------------------------
  # Instance helpers
  # -------------------------------------------------

  # For display in UI/cards
  def current_title
    # Choose best headline-ish label for profile cards
    headline.presence ||
      desired_role_primary.presence ||
      desired_role_secondary.presence
  end

  def full_location
    [ location_city, location_country ].compact_blank.join(", ")
  end

  def actively_looking?
    availability_status.to_s.downcase == "active"
  end

  def remote_friendly?
    open_to_remote
  end

  # Backward compatibility helper: some of your old views might still call `full_name`
  # If you still store first_name/last_name for now, we gracefully join them.
  def full_name
    [
      try(:first_name),
      try(:last_name)
    ].compact_blank.join(" ")
  end

  # FriendlyId wants this to decide the slug value
  def slug_source
    # Priority: user-chosen handle > display_name > fallback
    public_handle.presence ||
      display_name.to_s.parameterize.presence ||
      "user-#{user_id}"
  end

  # FriendlyId: regenerate slug if key identity fields change
  def should_generate_new_friendly_id?
    slug.blank? ||
      will_save_change_to_public_handle? ||
      will_save_change_to_display_name?
  end

  # When Rails prints this object (in logs, selects, etc.)
  def to_s
    display_name.presence ||
      public_handle.presence ||
      "User #{user_id}"
  end

  private

  # Make sure public_handle is always lowercase and URL-friendly
  def normalize_public_handle
    return if public_handle.blank?

    self.public_handle = public_handle.to_s.strip.downcase.parameterize
  end

  # If user edited profile, consider them "active" now.
  # We only update last_active_at automatically when last_edited_at changes.
  def sync_last_active_timestamp
    if will_save_change_to_last_edited_at?
      self.last_active_at = Time.current
    end
  end
end
