# db/seeds.rb
require "securerandom"
require "faker"

puts "Seeding 100 users → 2 companies each → ≥10 jobs/company…"

NUM_USERS            = 100
COMPANIES_PER_USER   = 2
JOBS_PER_COMPANY_MIN = 10
DEFAULT_PASSWORD     = "password123!"

EMPLOYMENT_TYPES = [ "Full-time", "Part-time", "Contract", "Internship", "Temporary" ]
PH_LOCATIONS     = [
  "Makati", "BGC (Taguig)", "Quezon City", "Pasig", "Ortigas",
  "Cebu City", "Davao City", "Iloilo City", "Remote (PH)"
]

# Faker::Config.random = Random.new(42) # uncomment for deterministic output
Faker::UniqueGenerator.clear

def ensure_confirmed!(user)
  if user.respond_to?(:skip_confirmation!)
    user.skip_confirmation!
  else
    user.confirmed_at ||= Time.current
  end
  user.save! if user.changed?
end

def random_location
  rand < 0.75 ? PH_LOCATIONS.sample : "#{Faker::Address.city}, #{Faker::Address.country}"
end

def random_employment_type
  EMPLOYMENT_TYPES.sample
end

def random_company_name
  Faker::Company.unique.name
end

def random_company_description
  "#{Faker::Company.catch_phrase}. #{Faker::Company.bs.titleize}."
end

def random_company_website
  # Avoid Faker URLs that sometimes miss a TLD
  "https://#{Faker::Internet.domain_name}"
end

def random_job_title
  # “Realistic” tech-ish titles with a language/stack flavor
  base       = Faker::Job.title # e.g., "Software Engineer", "QA Engineer", etc.
  seniority  = %w[Junior Mid Senior Lead Principal].sample
  lang       = Faker::ProgrammingLanguage.name # Ruby, Go, Python, etc.
  # Remove duplicated Senior/Lead from base to avoid "Senior Senior …"
  clean_base = base.gsub(/\b(Junior|Senior|Lead|Principal)\b/i, '').squeeze(" ").strip
  "#{seniority} #{clean_base} (#{lang})".squeeze(" ").strip
end

def random_job_description(company_name, title)
  para1 = Faker::Lorem.paragraph(sentence_count: 3)
  para2 = Faker::Lorem.paragraph(sentence_count: 3)
  [
    "#{company_name} is hiring a #{title}.",
    Faker::Company.catch_phrase,
    para1,
    "You’ll collaborate with product/design, write maintainable code, review PRs, and ship iteratively.",
    para2
  ].join(" ")
end

def create_job_for!(company, owner)
  title = random_job_title
  job   = company.jobs.new(
    title:           title,
    description:     random_job_description(company.name, title),
    location:        random_location,
    employment_type: random_employment_type
  )

  # Always set jobs.user_id even if the model stopped declaring belongs_to :user
  if job.has_attribute?(:user_id)
    job.write_attribute(:user_id, owner.id)
  else
    # Fallback if association still exists
    job.user = owner if job.respond_to?(:user=)
  end

  job.save!
  job
end

ActiveRecord::Base.transaction do
  (1..NUM_USERS).each do |i|
    email = format("seeduser-%03d@example.test", i)

    user = User.find_or_initialize_by(email: email)
    if user.new_record?
      user.password = DEFAULT_PASSWORD
      user.role     = :user
      user.save!
    end
    ensure_confirmed!(user)

    # Ensure the user has exactly 2 companies (top up if fewer)
    have = user.companies.count
    if have < COMPANIES_PER_USER
      ((have + 1)..COMPANIES_PER_USER).each do |_n|
        company = user.companies.create!(
          name:        random_company_name,
          description: random_company_description,
          website:     random_company_website
        )

        # Seed minimum jobs
        JOBS_PER_COMPANY_MIN.times { create_job_for!(company, company.user) }
      end
    end

    # Top up any existing company that’s below the min jobs
    user.companies.find_each do |company|
      missing = JOBS_PER_COMPANY_MIN - company.jobs.count
      next if missing <= 0
      missing.times { create_job_for!(company, company.user) }
    end
  end
end

puts "Done."
puts "Users:     #{User.count}"
puts "Companies: #{Company.count}"
puts "Jobs:      #{Job.count}"
puts "Example login → email: seeduser-001@example.test  password: #{DEFAULT_PASSWORD}"
