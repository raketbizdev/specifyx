json.extract! job, :id, :title, :description, :location, :employment_type, :user_id, :slug, :created_at, :updated_at
json.url job_url(job, format: :json)
