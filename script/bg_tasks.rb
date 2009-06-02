# Tipically executed by a cron job.
#
# Example (run every hour at minute 5):
# 
#   5 * * * * RAILS_ENV=production /home/user/apps/mogok/script/runner /home/user/apps/mogok/script/bg_tasks.rb

BgTasks::Dispatcher.exec








