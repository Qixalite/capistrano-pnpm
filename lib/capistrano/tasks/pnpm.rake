namespace :pnpm do
  desc <<-DESC
        Install the project dependencies via pnpm. By default, devDependencies \
        will not be installed. The install command is executed \
        with the --production, --silent and --no-spin flags.

        You can override any of these defaults by setting the variables shown below.

          set :pnpm_target_path, nil
          set :pnpm_flags, '--production --silent --no-spin'
          set :pnpm_roles, :all
          set :pnpm_env_variables, {}
          set :pnpm_method, 'install'
    DESC
  task :install do
    on roles fetch(:pnpm_roles) do
      within fetch(:pnpm_target_path, release_path) do
        with fetch(:pnpm_env_variables, {}) do
          execute :pnpm, fetch(:pnpm_method), fetch(:pnpm_flags)
        end
      end
    end
  end

  before 'deploy:updated', 'pnpm:install'

  desc <<-DESC
        Remove extraneous packages via pnpm. This command is executed within \
        the same context as npm install using the npm_roles and npm_target_path \
        variables.

        By default prune will be executed with the --production flag.  You can \
        override this default by setting the variable shown below.

          set :pnpm_prune_flags, '--production'

        This task is strictly opt-in.  If you want to run it on every deployment \
        before you run npm install, add the following to your deploy.rb.

          before 'pnpm:install', 'pnpm:prune'
    DESC
  task :prune do
    on roles fetch(:pnpm_roles) do
      within fetch(:pnpm_target_path, release_path) do
        execute :pnpm, 'prune', fetch(:pnpm_prune_flags)
      end
    end
  end

  desc <<-DESC
        Rebuild via pnpm. This command is executed within the same context \
        as pnpm install using the pnpm_roles and pnpm_target_path \
        variables.

        This task is strictly opt-in. The main reason you'll want to run this \
        would be after changing npm versions on the server.
    DESC
  task :rebuild do
    on roles fetch(:pnpm_roles) do
      within fetch(:pnpm_target_path, release_path) do
        with fetch(:pnpm_env_variables, {}) do
          execute :pnpm, 'rebuild'
        end
      end
    end
  end
end

namespace :load do
  task :defaults do
    set :pnpm_flags, %w(--production --silent --no-progress)
    set :pnpm_prune_flags, '--production'
    set :pnpm_roles, :all
    set :pnpm_method, 'install'
  end
end
