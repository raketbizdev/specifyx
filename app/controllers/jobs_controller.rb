# app/controllers/jobs_controller.rb
class JobsController < ApplicationController
  before_action :authenticate_user!, except: %i[index show listings]
  before_action :set_company_from_nested, only: %i[index new create]
  before_action :authorize_company_owner!, only: %i[new create]
  before_action :set_job, only: %i[show edit update destroy]
  before_action :authorize_owner!, only: %i[edit update destroy]

  # GET /jobs          (public list)
  # GET /companies/:company_id/jobs  (owner/admin management view)
  def index
    if @company.present?
      unless current_user&.admin? || @company.user_id == current_user&.id
        return redirect_to jobs_path, alert: "Not authorized."
      end
      @jobs = @company.jobs.order(created_at: :desc).includes(:company)
    else
      @jobs = Job.order(created_at: :desc).includes(company: :user)
    end
  end

  # GET /jobs/listings?q=rails+remote&employment_type=Full-time&location=Pasig
  # Public searchable listings page (separate from index)
  def listings
    @q = params[:q].to_s.strip
    scope = Job.includes(company: :user).order(created_at: :desc)

    if @q.present?
      tokens  = @q.split(/[,\s]+/).reject(&:blank?).first(5) # up to 5 terms
      clauses = []
      binds   = []

      tokens.each do |t|
        like = "%#{ActiveRecord::Base.sanitize_sql_like(t)}%"
        clauses << <<~SQL.squish
          (jobs.title ILIKE ?
           OR jobs.location ILIKE ?
           OR jobs.employment_type ILIKE ?
           OR jobs.description ILIKE ?
           OR companies.name ILIKE ?)
        SQL
        5.times { binds << like }
      end

      scope = scope.joins(:company).where(clauses.join(" AND "), *binds)
    end

    if params[:employment_type].present?
      scope = scope.where(employment_type: params[:employment_type])
    end

    if params[:location].present?
      loc = "%#{ActiveRecord::Base.sanitize_sql_like(params[:location])}%"
      scope = scope.where("jobs.location ILIKE ?", loc)
    end

    # Plug your paginator here if desired (e.g., Kaminari/Pagy)
    @jobs = scope
  end

  # GET /jobs/:id
  def show; end

  # GET /companies/:company_id/jobs/new
  def new
    @job = @company.jobs.new
  end

  # POST /companies/:company_id/jobs
  def create
    @company = Company.friendly.find(params[:company_id])
    @job = @company.jobs.build(job_params)

    # TEMP: satisfy old NOT NULL jobs.user_id until migration removes it
    @job.user_id ||= current_user.id if Job.column_names.include?("user_id")

    if @job.save
      redirect_to @job, notice: "Job created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /jobs/:id/edit
  def edit; end

  # PATCH/PUT /jobs/:id
  def update
    if @job.update(job_params)
      redirect_to @job, notice: "Job updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /jobs/:id
  def destroy
    @job.destroy
    redirect_to company_path(@job.company), notice: "Job deleted."
  end

  private

  def set_company_from_nested
    return unless params[:company_id].present?
    @company = Company.friendly.find(params[:company_id])
  end

  def authorize_company_owner!
    return unless @company # only applies to nested actions
    return if current_user&.admin? || @company.user_id == current_user&.id
    redirect_to companies_path, alert: "Not authorized."
  end

  def set_job
    @job = Job.friendly.find(params[:id])
  end

  def authorize_owner!
    return if current_user&.admin? || @job.company.user_id == current_user&.id
    redirect_to @job, alert: "Not authorized."
  end

  def job_params
    params.require(:job).permit(:title, :description, :location, :employment_type)
  end
end
