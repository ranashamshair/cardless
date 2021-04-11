# frozen_string_literal: true

# config valid for current version and patch releases of Capistrano
lock '~> 3.15.0'

set :application, 'distro_payment'
set :repo_url, 'https://ranashamshair:numlock1234545@github.com/ranashamshair/cardless.git'

set :deploy_to, '/home/ubuntu/distro_payment'

set :branch, 'master'
append :linked_files, 'config/database.yml', 'config/secrets.yml', 'config/application.yml'
append :linked_dirs, 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle'
set :use_sudo, true
# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, "/var/www/my_app_name"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# append :linked_files, "config/database.yml"

# Default value for linked_dirs is []
# append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
set :keep_releases, 3

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure
# namespace :rails do
#     desc "Remote console"
#     task :console do
#       on roles(:app) do |h|
#         run_interactively "bundle exec rails console #{fetch(:rails_env)}", h.user
#       end
#     end

#     desc "Remote dbconsole"
#     task :dbconsole do
#       on roles(:app) do |h|
#         run_interactively "bundle exec rails dbconsole #{fetch(:rails_env)}", h.user
#       end
#     end

#     def run_interactively(command, user)
#       info "Running `#{command}` as #{user}@#{host}"
#       exec %Q(ssh #{user}@#{host} -t "bash --login -c 'cd #{fetch(:deploy_to)}/current && #{command}'")
#     end
#   end
