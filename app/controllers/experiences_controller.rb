class ExperiencesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_profile
  before_action :set_experience, only: [ :edit, :update, :destroy ]

  # GET /profile/experiences
  def index
    @experiences = @profile.experiences.order(start_date: :desc)
  end

  # GET /profile/experiences/new
  def new
    @experience = @profile.experiences.build(
      is_current: false,
      employment_type: "Full-time"
    )
  end

  # POST /profile/experiences
  def create
    @experience = @profile.experiences.build(experience_params)

    if @experience.save
      @profile.update(last_edited_at: Time.current)
      redirect_to profile_experiences_path, notice: "Experience added."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /profile/experiences/:id/edit
  def edit
  end

  # PATCH/PUT /profile/experiences/:id
  def update
    if @experience.update(experience_params)
      @profile.update(last_edited_at: Time.current)
      redirect_to profile_experiences_path, notice: "Experience updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /profile/experiences/:id
  def destroy
    @experience.destroy
    @profile.update(last_edited_at: Time.current)
    redirect_to profile_experiences_path, notice: "Experience removed."
  end

  private

  def set_profile
    # only allow current_user to manage their own experience
    @profile = current_user.profile or redirect_to(edit_profile_path, alert: "Create your profile first.")
  end

  def set_experience
    @experience = @profile.experiences.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to profile_experiences_path, alert: "Experience not found."
  end

  def experience_params
    params.require(:experience).permit(
      :job_title,
      :company_name,
      :company_location,
      :employment_type,
      :start_date,
      :end_date,
      :is_current,
      :impact_summary
    )
  end
end
