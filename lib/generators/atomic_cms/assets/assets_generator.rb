module AtomicCms
  module Generators
    class AssetsGenerator < Rails::Generators::Base
      def install_bitters
        run "bitters install --path ./app/assets/stylesheets"
      end

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
          '@import "bourbon";',
          '@import "neat";',
          '@import "base/variables";',
          '@import "base/grid-settings";',
          '@import "atomic_cms";',
          '',
          '#component_preview {',
          '  @import "base/buttons";',
          '  @import "base/forms";',
          '  @import "base/lists";',
          '  @import "base/tables";',
          '  @import "base/typography";',
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
