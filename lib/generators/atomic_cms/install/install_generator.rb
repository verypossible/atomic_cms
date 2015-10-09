module AtomicCms
  module Generators
    class InstallGenerator < Rails::Generators::Base
      desc <<-DESC.strip_heredoc
        Setup AtomicCms for initial use.
      DESC

      def install_active_admin
        setup_cms_route_engine
        setup_active_admin
        initialize_active_admin_assets
      end

      private

      def initialize_active_admin_assets
        generate 'atomic_cms:assets'
      end

      def setup_active_admin
        gem 'activeadmin', '1.0.0.pre2'
        flags = ''
        flags << '--skip-users' unless Gem.loaded_specs.keys.include?('devise')

        generate 'active_admin:install', flags
      end

      def setup_cms_route_engine
        route 'mount AtomicCms::Engine => "/atomic_cms"'
      end
    end
  end
end
