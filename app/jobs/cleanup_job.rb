class CleanupJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # first get cleanup range as anything older than 48 hrs
    today = Date.today
    now = DateTime.now.utc
    cutoff = now - 48.hours
    # select measurements
    measurements = Measurement.all.where("created_at <= ?", cutoff)
    # select tasks - anything completed more than X hrs ago that doesn't have a future due-date
    tasks = Task.all.where("completed = ? AND due_date < ? AND updated_at <= ?", true, today, cutoff)
    # select waterings - anything completed more than X hrs ago
    waterings = Watering.all.where("done = ? AND updated_at <= ?", true, cutoff)
    # select alerts - anything that no longer applies
    alerts = WeatherAlert.all.where("apply_until <= ?", cutoff)
    # delete if any results
    measurements.destroy_all unless measurements.empty?
    tasks.destroy_all unless tasks.empty?
    waterings.destroy_all unless waterings.empty?
    alerts.destroy_all unless alerts.empty?
  end
end
