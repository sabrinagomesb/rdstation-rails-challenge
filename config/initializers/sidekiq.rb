gSidekiq.configure_server do |config|
  config.on(:startup) do
    schedule_file = 'config/sidekiq_scheduler.yml'

    Sidekiq::Scheduler.reload_schedule! if File.exist?(schedule_file) && Sidekiq.server?
  end
end
