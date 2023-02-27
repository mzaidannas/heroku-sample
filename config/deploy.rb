require 'mina/bundler'
require 'mina/rails'
require 'mina/git'
require 'mina/rbenv'  # for rbenv support. (https://rbenv.org)
# require 'mina/rvm'    # for rvm support. (https://rvm.io)
require 'mina/puma'
require 'mina_sidekiq/tasks'

# Basic settings:
#   domain       - The hostname to SSH to.
#   deploy_to    - Path to deploy into.
#   repository   - Git repo to clone from. (needed by mina/git)
#   branch       - Branch name to deploy. (needed by mina/git)

set :rails_env, 'production'

set :application_name, 'heroku-sample'
set :domain, 'heroku-sample.mzaidannas.me'
set :deploy_to, '/home/ubuntu/heroku-sample'
set :repository, 'https://github.com/mzaidannas/heroku-sample.git'
set :branch, 'master'

# Optional settings:
  set :user, 'ubuntu'          # Username in the server to SSH to.
  set :port, '22'              # SSH port number.
  set :forward_agent, true     # SSH forward_agent.


# Mina sidekiq settings
set :init_system, :systemd
set :service_unit_path, '/home/ubuntu/.config/systemd/user'

# Shared dirs and files will be symlinked into the app-folder by the 'deploy:link_shared_paths' step.
# Some plugins already add folders to shared_dirs like `mina/rails` add `public/assets`, `vendor/bundle` and many more
# run `mina -d` to see all folders and files already included in `shared_dirs` and `shared_files`
set :shared_dirs, fetch(:shared_dirs, []).push('tmp/pids', 'tmp/sockets')
set :shared_files, fetch(:shared_files, []).push('config/database.yml', '.env')

set :nodenv_path, '$HOME/.nodenv'

task :'nodenv:load' do
  comment %(Loading nodenv)
  command %(export NODENV_ROOT="#{fetch(:nodenv_path)}")
  command %(export PATH="#{fetch(:nodenv_path)}/bin:$PATH")
  command %(
    if ! which nodenv >/dev/null; then
      echo "! nodenv not found"
      echo "! If nodenv is installed, check your :nodenv_path setting."
      exit 1
    fi
  )
  command %{eval "$(nodenv init -)"}
end

# This task is the environment that is loaded for all remote run commands, such as
# `mina deploy` or `mina rake`.
task :remote_environment do
  # If you're using rbenv, use this to load the rbenv environment.
  # Be sure to commit your .ruby-version or .rbenv-version to your repository.
  invoke :'rbenv:load'
  invoke :'nodenv:load'

  # For those using RVM, use this to load an RVM version@gemset.
  # invoke :'rvm:use', 'ruby-3.2.0@default'
end

# Put any custom commands you need to run at setup
# All paths in `shared_dirs` and `shared_paths` will be created on their own.
task :setup do
  command %(curl -fsSL https://github.com/rbenv/rbenv-installer/raw/HEAD/bin/rbenv-installer | bash)
  command %(git -C ~/.rbenv/plugins/ruby-build pull)
  command %(rbenv install 3.2.0 --skip-existing)
  command %(rbenv local 3.2.0)
  command %(rbenv exec gem install bundler -v 2.4.1)
  command %(curl -fsSL https://raw.githubusercontent.com/nodenv/nodenv-installer/master/bin/nodenv-installer | bash)
  command %(git -C ~/.nodenv/plugins/node-build pull)
  command %(nodenv install 18.9.0 --skip-existing)
  command %(nodenv local 18.9.0)
  command %(nodenv exec npm install -g yarn)

  # command %{rvm install ruby-3.2.0}
  # command %{gem install bundler}

  # Puma needs a place to store its pid file and socket file.
  command %{mkdir -p "#{fetch(:shared_path)}/config"}
  command %{touch "#{fetch(:shared_path)}/config/database.yml"}
  command %{touch "#{fetch(:shared_path)}/.env"}

  # Enable user level systemd services support for sidekiq
  command %(loginctl enable-linger ubuntu)
  invoke :'sidekiq:install'
end

desc "Deploys the current version to the server."
task :deploy do
  # uncomment this line to make sure you pushed your local branch to the remote origin
  invoke :'git:ensure_pushed'
  deploy do
    # Put things that will set up an empty directory into a fully set-up
    # instance of your project.
    invoke :'git:clone'
    invoke :'sidekiq:quiet'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'rails:db_create'
    invoke :'rails:db_migrate'
    invoke :'rails:assets_precompile'
    invoke :'deploy:cleanup'

    on :launch do
      in_path(fetch(:current_path)) do
        command %{mkdir -p tmp/}
      invoke :'puma:restart'
      invoke :'sidekiq:restart'
      end
    end
  end

  # you can use `run :local` to run tasks on local machine before of after the deploy scripts
  # run(:local){ say 'done' }
end

# For help in making your deploy script, see the Mina documentation:
#
#  - https://github.com/mina-deploy/mina/tree/master/docs
