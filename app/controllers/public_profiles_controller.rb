# app/controllers/public_profiles_controller.rb
class PublicProfilesController < ApplicationController
  # Public endpoint, no auth
  before_action :set_profile

  def show
    unless @profile.public?
      redirect_to root_path, alert: "This profile is private." and return
    end

    # HTTP caching for faster SEO/public loads
    fresh_when etag: @profile, last_modified: @profile.updated_at, public: true
  end

  private

  def set_profile
    @profile = Profile.friendly.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "Profile not found."
  end
end
