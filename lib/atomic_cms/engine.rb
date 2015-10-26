module AtomicCms
  require 'paperclip'
  class Engine < ::Rails::Engine
    isolate_namespace AtomicCms

    config.generators do |g|
      g.test_framework :rspec, fixture: false
      g.fixture_replacement :factory_girl, dir: 'spec/factories'
      g.assets false
      g.helper false
    end

    initializer "atomic_cms.action_controller" do |_app|
      ActiveSupport.on_load :action_controller do
        helper AtomicCms::ComponentHelper
      end
    end
  end
end
