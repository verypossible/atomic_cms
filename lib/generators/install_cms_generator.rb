class InstallCmsGenerator < Rails::Generators::Base
  def install_active_admin
    flags = []
    flags << '--skip-users' unless Gem.loaded_specs.keys.include?('devise')

    generate 'active_admin:install', flags
  end
end
