class InstallCmsGenerator < Rails::Generators::Base
  def install_active_admin
    gem 'activeadmin', '1.0.0.pre2'
    flags = ''
    flags << '--skip-users' unless Gem.loaded_specs.keys.include?('devise')

    generate 'active_admin:install', flags
  end
end
