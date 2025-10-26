# app/controllers/job_applications_controller.rb
class JobApplicationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_job

  def index
    owner = (@job.company.user_id == current_user.id)
    return redirect_to @job, alert: "Not authorized." unless owner || current_user.admin?

    @job_applications = @job.job_applications.includes(:user)
  end

  def create
    ja = @job.job_applications.build(job_application_params.merge(user_id: current_user.id))
    if ja.save
      redirect_to @job, notice: "Application submitted."
    else
      redirect_to @job, alert: ja.errors.full_messages.to_sentence
    end
  end

  def destroy
    ja = @job.job_applications.find(params[:id])

    owner = (@job.company.user_id == current_user.id)
    applicant = (ja.user_id == current_user.id)
    return redirect_to @job, alert: "Not authorized." unless applicant || owner || current_user.admin?

    ja.destroy
    redirect_to @job, notice: "Application removed."
  end

  private

  def set_job
    @job = Job.friendly.find(params[:job_id])
  end

  def job_application_params
    params.require(:job_application).permit(:cover_letter)
  end
end
