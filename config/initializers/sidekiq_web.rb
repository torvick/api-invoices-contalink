# config/initializers/sidekiq_web.rb
require "sidekiq/web"
require "sidekiq/cron/web"
require "rack/session/cookie"

Sidekiq::Web.use Rack::Session::Cookie,
  key:    "_sidekiq.session",
  secret: Rails.application.secret_key_base,
  same_site: true,
  max_age: 86_400 