# Tipically executed by a cron job.
#
# Example (run every hour at minute 5):
# 
#   5 * * * * RAILS_ENV=production /path/to/app/root/script/runner /path/to/app/root/script/bg_tasks.rb

BgTasks::Dispatcher.exec








