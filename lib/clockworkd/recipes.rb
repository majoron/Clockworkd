# Capistrano Recipes for managing clockworkd
#
# Add these callbacks to have the clockworkd process restart when the server
# is restarted:
#
#   after "deploy:stop",    "clockworkd:stop"
#   after "deploy:start",   "clockworkd:start"
#   after "deploy:restart", "clockworkd:restart"
#
# If you want to use command line options, for example to start multiple workers,
# define a Capistrano variable clockworkd_args:
#
#   set :clockworkd_args, "-n 2"
#
# If you've got clockworkd workers running on a servers, you can also specify
# which servers have clockworkd running and should be restarted after deploy.
#
#   set :clockworkd_server_role, :worker
#

Capistrano::Configuration.instance.load do
  namespace :clockworkd do
    def rails_env
      fetch(:rails_env, false) ? "RAILS_ENV=#{fetch(:rails_env)}" : ''
    end

    def args
      fetch(:clockworkd_args, "")
    end

    def roles
      fetch(:clockworkd_server_role, :app)
    end

    desc "Stop the clockworkd process"
    task :stop, :roles => lambda { roles } do
      run "cd #{current_path};#{rails_env} script/clockworkd stop"
    end

    desc "Start the clockworkd process"
    task :start, :roles => lambda { roles } do
      run "cd #{current_path};#{rails_env} script/clockworkd start #{args}"
    end

    desc "Restart the clockworkd process"
    task :restart, :roles => lambda { roles } do
      run "cd #{current_path};#{rails_env} script/clockworkd restart #{args}"
    end
  end
end