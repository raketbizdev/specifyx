# app/controllers/profiles_controller.rb
class ProfilesController < ApplicationController
  # /profile is always for the signed-in user
  before_action :authenticate_user!
  before_action :ensure_profile!  # guarantees @profile for show/edit/update/create

  # GET /profile
  def show
    # @profile is set by ensure_profile!
  end

  # GET /profile/new
  # We don't actually use a "new" view for singleton profile; redirect to edit.
  def new
    redirect_to edit_profile_path, notice: "You can edit your profile here."
  end

  # POST /profile
  # Handles first-time save of a just-created profile or resave
  def create
    if @profile.update(profile_params)
      @profile.update(last_edited_at: Time.current)
      redirect_to profile_path, notice: "Profile saved."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # GET /profile/edit
  def edit
    # @profile is already loaded by ensure_profile!
    @profile.experiences.build if @profile.experiences.empty?
  end

  # PATCH/PUT /profile
  def update
    if @profile.update(profile_params)
      @profile.update(last_edited_at: Time.current)
      redirect_to profile_path, notice: "Profile updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  # Ensures current_user has a profile and assigns @profile.
  # If not present, we auto-create a minimal record so pages won't 500.
  def ensure_profile!
    @profile = current_user.profile
    return if @profile.present?

    # generate a safe handle from email for public_handle/display_name
    base_handle =
      current_user.email.to_s.split("@").first.presence ||
      "user-#{current_user.id}"

    begin
      @profile = current_user.create_profile!(
        display_name: base_handle,
        headline: nil,
        summary: nil,

        # visibility defaults
        public_handle: base_handle.parameterize, # can be changed later
        is_public: true,
        allow_contact: true,
        show_fullname: true,

        # work prefs baseline
        availability_status: "Passive", # means not actively looking
        open_to_remote: true,
        open_to_relocation: false,
        salary_currency: "PHP",

        # timestamps / freshness
        last_active_at: Time.current,
        last_edited_at: Time.current
      )
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error(
        "[ProfilesController] auto-create profile failed for user #{current_user.id}: #{e.message}"
      )
      redirect_to root_path,
                  alert: "Couldn’t prepare your profile. Please try again." and return
    end
  end

  # Strong params: only allow fields a normal user can edit about themselves.
  # We EXCLUDE internal score / verification fields so users can't set them.
  def profile_params
    params.require(:profile).permit(
      # branding / about
      :display_name,
      :headline,
      :summary,
      :avatar_url,
      :banner_url,

      # links / presence
      :website_url,
      :linkedin_url,
      :github_url,
      :portfolio_url,

      # visibility / privacy
      :public_handle,
      :is_public,
      :allow_contact,
      :show_fullname,

      # location / work situation
      :location_city,
      :location_country,
      :open_to_remote,
      :open_to_relocation,
      :work_authorization,
      :seniority_level,

      # job search targeting
      :desired_role_primary,
      :desired_role_secondary,
      :employment_type_preference,
      :min_salary_expectation,
      :salary_currency,
      :availability_status,
      :available_from
    )
  end
end
