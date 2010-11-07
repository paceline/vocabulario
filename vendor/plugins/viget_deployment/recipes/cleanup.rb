require 'rubygems'
require 'active_support'

namespace :deploy do
  desc <<-DESC
    Clean up releases from before a given time. By default, this time is midnight \
    on the current day, but can be changed with the purge_before_time variable. \
    Note that because releases are timestamped in UTC, this task calculates the \
    threshold in UTC as well. This task will abort without removing anything if \
    all of the releases on the server fall below the threshold.
  DESC
  task :cleanup_before_time, :except => { :no_release => true } do
    threshold = fetch(:purge_before_time, Time.now.midnight).utc
    logger.info "considering removing releases from before #{threshold}"
    old_releases = releases.select{|r| r.to_i < threshold.strftime("%Y%m%d%H%M%S").to_i}
    if old_releases.empty?
      logger.important "no old releases to clean up"
    elsif old_releases.length == releases.length
      logger.important "refusing to proceed, as doing so would remove all releases"
    else
      logger.info "keeping #{releases.length - old_releases.length} of #{releases.length} deployed releases"
      directories = old_releases.map {|release| File.join(releases_path, release)}.join(" ")
      try_sudo "rm -rf #{directories}"
    end
  end
end