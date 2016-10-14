# frozen_string_literal: true
module Onotole
  module BeforeBundlePatch
    def add_user_gems
      add_to_user_choise(:devise_bootstrap_views) if user_choose?(:bootstrap3_sass) && user_choose?(:devise)
      GEMPROCLIST.each do |g|
        send "add_#{g}_gem" if user_choose? g.to_sym
      end
    end

    def setup_default_gems
      add_to_user_choise(:normalize)
    end

    def add_haml_gem
      inject_into_file('Gemfile', "\ngem 'haml-rails'", after: '# user_choice')
    end

    def add_dotenv_heroku_gem
      inject_into_file('Gemfile', "\n  gem 'dotenv-heroku'",
                       after: 'group :development do')
      append_file 'Rakefile', %(\nrequire 'dotenv-heroku/tasks' if ENV['RACK_ENV'] == 'test' || ENV['RACK_ENV'] == 'development'\n)
    end

    def add_slim_gem
      inject_into_file('Gemfile', "\ngem 'slim-rails'", after: '# user_choice')
      inject_into_file('Gemfile', "\n  gem 'html2slim'", after: 'group :development do')
    end

    def add_rails_db_gem
      inject_into_file('Gemfile', "\n  gem 'rails_db'\n  gem 'axlsx_rails'", after: '# user_choice')
    end

    def add_rubocop_gem
      inject_into_file('Gemfile', "\n  gem 'rubocop', require: false",
                       after: 'group :development do')
      copy_file 'rubocop.yml', '.rubocop.yml'
    end

    def add_guard_gem
      t = <<-TEXT.chomp

  gem 'guard'
  gem 'guard-livereload', '~> 2.4', require: false
  gem 'guard-puma', require: false
  gem 'guard-migrate', require: false
  gem 'guard-rspec', require: false
  gem 'guard-bundler', require: false
      TEXT
      inject_into_file('Gemfile', t, after: 'group :development do')
    end

    def add_guard_rubocop_gem
      if user_choose?(:guard) && user_choose?(:rubocop)
        inject_into_file('Gemfile', "\n  gem 'guard-rubocop'",
                         after: 'group :development do')
      else
        say_color RED, 'You need Guard & Rubocop gems for this add-on'
      end
    end

    def add_meta_request_gem
      inject_into_file('Gemfile',
                       "\n  gem 'meta_request' # link for chrome add-on. "\
                       'https://chrome.google.com/webstore/detail/'\
                       'railspanel/gjpfobpafnhjhbajcjgccbbdofdckggg',
                       after: 'group :development do')
    end

    def add_faker_gem
      inject_into_file('Gemfile', "\n  gem 'faker'", after: 'group :development, :test do')
    end

    def add_bundler_audit_gem
      copy_file 'bundler_audit.rake', 'lib/tasks/bundler_audit.rake'
      append_file 'Rakefile', %(\ntask default: "bundler:audit"\n)
    end

    def add_bootstrap3_sass_gem
      inject_into_file('Gemfile', "\ngem 'bootstrap-sass', '~> 3.3.6'",
                       after: '# user_choice')
    end

    def add_airbrake_gem
      inject_into_file('Gemfile', "\ngem 'airbrake'",
                       after: '# user_choice')
    end

    def add_bootstrap3_gem
      inject_into_file('Gemfile', "\ngem 'twitter-bootstrap-rails'",
                       after: '# user_choice')
      inject_into_file('Gemfile', "\ngem 'devise-bootstrap-views'",
                       after: '# user_choice') if user_choose?(:devise)
    end

    def add_devise_gem
      devise_conf = <<-TEXT

  # v.3.5 syntax. will be deprecated in 4.0
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_in) do |user_params|
      user_params.permit(:email, :password, :remember_me)
    end

    devise_parameter_sanitizer.permit(:sign_up) do |user_params|
      user_params.permit(:email, :password, :password_confirmation)
    end
  end
  protected :configure_permitted_parameters
    TEXT
      inject_into_file('Gemfile', "\ngem 'devise'", after: '# user_choice')
      inject_into_file('app/controllers/application_controller.rb',
                       "\nbefore_action :configure_permitted_parameters, if: :devise_controller?",
                       after: 'class ApplicationController < ActionController::Base')

      inject_into_file('app/controllers/application_controller.rb', devise_conf,
                       after: 'protect_from_forgery with: :exception')
      copy_file 'devise_rspec.rb', 'spec/support/devise.rb'
      copy_file 'devise.ru.yml', 'config/locales/devise.ru.yml'
    end

    def add_responders_gem
      inject_into_file('Gemfile', "\ngem 'responders'", after: '# user_choice')
    end

    def add_hirbunicode_gem
      inject_into_file('Gemfile', "\ngem 'hirb-unicode'", after: '# user_choice')
    end

    def add_tinymce_gem
      inject_into_file('Gemfile', "\ngem 'tinymce-rails'", after: '# user_choice')
      inject_into_file('Gemfile', "\ngem 'tinymce-rails-langs'", after: '# user_choice')
      copy_file 'tinymce.yml', 'config/tinymce.yml'
    end

    def add_annotate_gem
      inject_into_file('Gemfile', "\n  gem 'annotate'", after: 'group :development do')
    end

    def add_overcommit_gem
      inject_into_file('Gemfile', "\n  gem 'overcommit'", after: 'group :development do')
      copy_file 'onotole_overcommit.yml', '.overcommit.yml'
      rubocop_overcommit = <<-OVER
  RuboCop:
    enabled: true
    description: 'Analyzing with RuboCop'
    required_executable: 'rubocop'
    flags: ['--format=emacs', '--force-exclusion', '--display-cop-names']
    install_command: 'gem install rubocop'
    include:
      - '**/*.gemspec'
      - '**/*.rake'
      - '**/*.rb'
      - '**/Gemfile'
      - '**/Rakefile'
      OVER
      append_file '.overcommit.yml', rubocop_overcommit if user_choose?(:rubocop)
    end

    def add_activerecord_import_gem
      inject_into_file('Gemfile', "\ngem 'activerecord-import'", after: '# user_choice')
    end

    def add_activeadmin_gem
      inject_into_file('Gemfile', "\ngem 'activeadmin', github: 'activeadmin'", after: '# user_choice')
      inject_into_file('Gemfile', "\ngem 'inherited_resources', github: 'activeadmin/inherited_resources'", after: '# user_choice')
      inject_into_file('Gemfile', "\ngem 'kaminari-i18n'", after: '# user_choice')
      copy_file 'activeadmin.en.yml', 'config/locales/activeadmin.en.yml'
      copy_file 'activeadmin.ru.yml', 'config/locales/activeadmin.ru.yml'
      # it still live https://github.com/Prelang/feedback/issues/14 and this patch helps
      run 'mkdir app/inputs'
      copy_file 'inet_input.rb', 'app/inputs/inet_input.rb'
    end

    # def add_administrate_gem
    #   inject_into_file('Gemfile', "\ngem 'administrate'", after: '# user_choice')
    # end

    def add_rails_admin_gem
      inject_into_file('Gemfile', "\ngem 'rails_admin'", after: '# user_choice')
    end

    def add_rubycritic_gem
      inject_into_file('Gemfile', "\n  gem 'rubycritic', :require => false",
                       after: 'group :development do')
    end

    def add_railroady_gem
      inject_into_file('Gemfile', "\n  gem 'railroady'", after: 'group :development do')
    end

    def add_typus_gem
      inject_into_file('Gemfile', "\n  gem 'typus', github: 'typus/typus'", after: '# user_choice')
    end

    def add_will_paginate_gem
      inject_into_file('Gemfile', "\ngem 'will_paginate', '~> 3.0.6'",
                       after: '# user_choice')
      inject_into_file('Gemfile', "\ngem 'will_paginate-bootstrap'",
                       after: '# user_choice') if user_choose?(:bootstrap3) ||
                                                  user_choose?(:bootstrap3_sass)
    end

    def add_kaminari_gem
      inject_into_file('Gemfile', "\ngem 'kaminari'", after: '# user_choice')
      inject_into_file('Gemfile', "\ngem 'kaminari-i18n'", after: '# user_choice')
      copy_file 'kaminari.rb', 'config/initializers/kaminari.rb'
      inject_into_file('Gemfile', "\ngem 'bootstrap-kaminari-views'",
                       after: '# user_choice') if user_choose?(:bootstrap3) ||
                                                  user_choose?(:bootstrap3_sass)
    end

    def add_active_admin_import_gem
      inject_into_file('Gemfile', "\ngem 'active_admin_import'", after: '# user_choice')
    end

    def add_active_admin_theme_gem
      inject_into_file('Gemfile', "\ngem 'active_admin_theme'", after: '# user_choice')
    end

    def add_paper_trail_gem
      inject_into_file('Gemfile', "\ngem 'paper_trail'", after: '# user_choice')
    end

    def add_validates_timeliness_gem
      inject_into_file('Gemfile', "\ngem 'validates_timeliness'", after: '# user_choice')
    end

    def add_active_skin_gem
      inject_into_file('Gemfile', "\ngem 'active_skin'", after: '# user_choice')
    end

    def add_flattened_active_admin_gem
      inject_into_file('Gemfile', "\ngem 'flattened_active_admin'", after: '# user_choice')
    end

    def add_font_awesome_sass_gem
      inject_into_file('Gemfile', "\ngem 'font-awesome-sass', '~> 4.5.0'", after: '# user_choice')
    end

    def add_cyrillizer_gem
      inject_into_file('Gemfile', "\ngem 'cyrillizer'", after: '# user_choice')
    end

    def add_ckeditor_gem
      inject_into_file('Gemfile', "\ngem 'ckeditor'", after: '# user_choice')
    end

    def add_devise_bootstrap_views_gem
      inject_into_file('Gemfile', "\ngem 'devise-bootstrap-views'", after: '# user_choice')
    end

    def add_axlsx_rails_gem
      inject_into_file('Gemfile', "\ngem 'axlsx_rails'", after: '# user_choice')
    end

    def add_axlsx_gem
      inject_into_file('Gemfile', "\ngem 'axlsx'", after: '# user_choice')
    end

    def add_face_of_active_admin_gem
      inject_into_file('Gemfile', "\ngem 'face_of_active_admin'", after: '# user_choice')
    end

    def add_prawn_gem
      inject_into_file('Gemfile', "\ngem 'prawn'", after: '# user_choice')
      inject_into_file('Gemfile', "\ngem 'prawn-table'", after: '# user_choice')
    end

    def add_fotoramajs_gem
      inject_into_file('Gemfile', "\ngem 'fotoramajs'", after: '# user_choice')
    end

    def add_geocoder_gem
      inject_into_file('Gemfile', "\ngem 'geocoder'", after: '# user_choice')
    end

    def add_gmaps4rails_gem
      inject_into_file('Gemfile', "\ngem 'gmaps4rails'", after: '# user_choice')
    end

    def add_underscore_rails_gem
      inject_into_file('Gemfile', "\ngem 'underscore-rails'", after: '# user_choice')
    end

    def add_image_optim_gem
      inject_into_file('Gemfile', "\n  gem 'image_optim_pack'", after: 'group :development do')
      inject_into_file('Gemfile', "\n  gem 'image_optim'", after: 'group :development do')
    end

    def add_mailcatcher_gem
      inject_into_file('Gemfile', "\n  gem 'mailcatcher'", after: 'group :development do')
    end

    def add_rack_cors_gem
      inject_into_file('Gemfile', "\ngem 'rack-cors', :require => 'rack/cors'", after: '# user_choice')
    end

    def add_rack_mini_profiler_gem
      inject_into_file('Gemfile', "\n  gem 'rack-mini-profiler', require: false", after: '# user_choice')
      copy_file 'rack_mini_profiler.rb', 'config/initializers/rack_mini_profiler.rb'
    end

    def add_newrelic_rpm_gem
      inject_into_file('Gemfile', "\ngem 'newrelic_rpm'", after: '# user_choice')
    end

    def add_active_admin_simple_life_gem
      inject_into_file('Gemfile', "\ngem 'active_admin_simple_life'", after: '# user_choice')
    end

    def add_flamegraph_gem
      inject_into_file('Gemfile', "\n  gem 'flamegraph'", after: 'group :development do')
    end

    def add_stackprof_gem
      inject_into_file('Gemfile', "\n  gem 'stackprof'", after: 'group :development do')
    end

    def add_redis_gem
      inject_into_file('Gemfile', "\ngem 'redis', '~>3.2'", after: '# user_choice')
    end

    def add_redis_rails_gem
      inject_into_file('Gemfile', "\ngem 'redis-rails'", after: '# user_choice')
    end

    def add_redis_namespace_gem
      inject_into_file('Gemfile', "\ngem 'redis-namespace'", after: '# user_choice')
    end

    def add_carrierwave_gem
      inject_into_file('Gemfile', "\ngem 'carrierwave', '~> 0.10.0'", after: '# user_choice')
      inject_into_file('Gemfile',
                       "\ngem 'mini_magick', '~> 4.5.0'",
                       after: '# user_choice') if AppBuilder.file_storage_name
    end

    def add_invisible_captcha_gem
      inject_into_file('Gemfile', "\ngem 'invisible_captcha'", after: '# user_choice')
    end

    def add_sitemap_generator_gem
      inject_into_file('Gemfile', "\n  gem 'sitemap_generator', :require => false", after: 'group :development do')
    end

    def add_materialize_sass_gem
      inject_into_file('Gemfile', "\ngem 'materialize-sass'", after: '# user_choice')
    end

    def add_active_record_doctor_gem
      inject_into_file('Gemfile', "\n  gem 'active_record_doctor'", after: 'group :development do')
    end

    def add_therubyracer_gem
      inject_into_file('Gemfile', "\n  gem 'therubyracer'", after: '# user_choice')
    end

    def add_pundit_gem
      inject_into_file('Gemfile', "\n  gem 'pundit'", after: '# user_choice')
    end

    def add_git_up_gem
      inject_into_file('Gemfile', "\n  gem 'git-up'", after: 'group :development do')
    end
  end
end
