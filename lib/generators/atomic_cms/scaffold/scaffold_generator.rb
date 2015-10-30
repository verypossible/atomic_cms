require "active_support/core_ext/string"

module AtomicCms
  module Generators
    class ScaffoldGenerator < Rails::Generators::Base
      argument :model_name, required: true

      desc <<-DESC.strip_heredoc
        Create a model, controller, view, admin resource, and route.
      DESC

      source_root File.expand_path("../../templates", __FILE__)

      def install_model_template
        setup_scaffold
        create_template(
          template_name: "model.erb",
          full_path: "app/models/#{@scaffold.model_file_name}.rb"
        )
      end

      def install_controller_template
        create_template(
          template_name: "controller.erb",
          full_path: "app/controllers/#{@scaffold.controller_file_name}_controller.rb"
        )
      end

      def install_admin_template
        create_template(
          template_name: "admin.erb",
          full_path: "app/admin/#{@scaffold.model_file_name}.rb"
        )
      end

      def install_show_view_template
        create_template(
          template_name: "show.html.slim",
          full_path: "app/views/#{@scaffold.view_folder}/show.html.slim"
        )
      end

      def create_migration
        generate "migration", "create#{@scaffold.model_name} name:string content:text"
      end

      def set_route
        inject_into_file "config/routes.rb", "\n  resources :#{@scaffold.controller_file_name}\n", after: /\/atomic_cms"/
      end

      private

      def setup_scaffold
        @scaffold = OpenStruct.new(
          model_name: model_name.singularize.titlecase,
          model_file_name: model_name.singularize.downcase.underscore,
          controller_name: model_name.pluralize.titlecase,
          controller_file_name: model_name.pluralize.downcase,
          view_folder: model_name.singularize.downcase.underscore
        )
      end

      def create_template(options)
        template(options[:template_name], options[:full_path])
      end
    end
  end
end
