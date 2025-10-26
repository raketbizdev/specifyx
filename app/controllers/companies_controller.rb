# app/controllers/companies_controller.rb
class CompaniesController < ApplicationController
  # Public pages
  before_action :authenticate_user!, except: [ :listings, :show ]

  before_action :set_company, only: [ :show, :edit, :update, :destroy ]
  before_action :authorize_company!, only: [ :edit, :update, :destroy ]

  PER_PAGE = 24

  # GET /company-listings?q=acme&page=2&per_page=24&has_jobs=1
  # Public searchable listings page (supports infinite scroll via Turbo Stream)
  def listings
    @q        = params[:q].to_s.strip
    @page     = params[:page].to_i
    @page     = 1 if @page < 1
    @per_page = (params[:per_page] || PER_PAGE).to_i.clamp(1, 100)

    scope = Company.left_joins(:jobs)
               .select("companies.*, COUNT(jobs.id) AS jobs_count")
               .group("companies.id")
               .order(created_at: :desc)

    if @q.present?
      like = "%#{ActiveRecord::Base.sanitize_sql_like(@q)}%"
      scope = scope.where(
        "companies.name ILIKE :q OR companies.description ILIKE :q OR companies.website ILIKE :q",
        q: like
      )
    end

    # Only companies that currently have jobs
    scope = scope.joins(:jobs).distinct if params[:has_jobs] == "1"
    @total_count = scope.unscope(:select, :group, :order).distinct.count(:id)

    @companies = scope.limit(@per_page).offset((@page - 1) * @per_page)
    @next_page  = @companies.size == @per_page ? @page + 1 : nil

    respond_to do |format|
      format.html          # renders listings.html.erb (first page)
      format.turbo_stream  # renders listings.turbo_stream.erb (append + replace pager)
    end
  end


  # GET /companies
  # Admin: all; User: own
  def index
    @companies =
      if current_user.admin?
        Company.order(created_at: :desc)
      else
        current_user.companies.order(created_at: :desc)
      end
  end

  # GET /companies/:id  (public)
  def show
    @jobs = @company.jobs.order(created_at: :desc)
  end

  # GET /companies/new
  def new
    @company = current_user.companies.new
  end

  # POST /companies
  def create
    @company = current_user.companies.new(company_params)
    if @company.save
      redirect_to @company, notice: "Company created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /companies/:id/edit
  def edit; end

  # PATCH/PUT /companies/:id
  def update
    if @company.update(company_params)
      redirect_to @company, notice: "Company updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /companies/:id
  def destroy
    if @company.destroy
      redirect_to companies_path, notice: "Company deleted."
    else
      msg = @company.errors.full_messages.presence || [ "Company could not be deleted." ]
      redirect_to @company, alert: msg.to_sentence
    end
  end

  private

  def set_company
    @company = Company.friendly.find(params[:id])
  end

  def authorize_company!
    return if current_user.admin? || @company.user_id == current_user.id
    head :forbidden
  end

  def company_params
    params.require(:company).permit(:name, :description, :website)
  end
end
