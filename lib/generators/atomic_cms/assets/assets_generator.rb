module AtomicCms
  module Generators
    class AssetsGenerator < Rails::Generators::Base
      def initialize_active_admin_javascript
        javascript_asset = 'app/assets/javascripts/active_admin.js.coffee'
        entries = [
          '#= require angular',
          '#= require angular-sanitize',
          '#= require atomic_cms'
        ]
        append_to_file( asset_file: javascript_asset, entries: entries )
      end

      def initialize_active_admin_scss
        scss_asset = 'app/assets/stylesheets/active_admin.scss'
        entries = [
          '@import "atomic_cms"',
          '',
          '#component_preview {',
          '  // When editing a page through Atomic CMS',
          '  // images with broken links should not be displayed.',
          '  img[src="image"] { display:none !important; }',
          '}'
        ]
        append_to_file( asset_file: scss_asset, entries: entries )
      end

      private

      def append_to_file(options)
        open(options[:asset_file], 'a') do |asset_file|
          options[:entries].each do |entry|
            asset_file.puts entry
          end
        end
      end
    end
  end
end
