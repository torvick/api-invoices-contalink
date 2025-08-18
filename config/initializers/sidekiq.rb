# config/initializers/sidekiq.rb
require "sidekiq"
require "sidekiq/cron/job"

redis_url = ENV.fetch("REDIS_URL", "redis://127.0.0.1:6379/0")

Sidekiq.configure_server do |config|
  config.redis = { url: redis_url, network_timeout: 5 }

  schedule_path = Rails.root.join("config/sidekiq_cron.yml")
  if File.exist?(schedule_path)
    Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_path)
  else
    schedule = {
      "top_selling_days_daily" => {
        "cron"        => "0 8 * * *",
        "class"       => "TopSellingDaysEmailJob",
        "queue"       => "default",
        "timezone"    => "America/Mexico_City",
        "description" => "Enviar Top 10 días con más venta (08:00 CDMX)"
      }
    }
    Sidekiq::Cron::Job.load_from_hash(schedule)
  end

  Sidekiq.logger.info("[cron] loaded #{Sidekiq::Cron::Job.all.size} job(s)")
end

Sidekiq.configure_client do |config|
  config.redis = { url: redis_url, network_timeout: 5 }
end
