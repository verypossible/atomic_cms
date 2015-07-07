module AtomicCms
  module HasComponents
    extend ActiveSupport::Concern

    included do
      extend ClassMethods
    end

    module ClassMethods
      def component_attr(name)
        define_method("set_default_#{name}") do
          write_attr(name, ArrayComponent.new.to_yaml) unless send(name)
        end

        after_initialize "set_default_#{name}"

        define_method("#{name}_object") do
          AtomicAssets::Component.from_yaml(send(name))
        end

        define_method("#{name}_object=") do |params|
          object = AtomicAssets::Component.from_hash(params)
          write_attribute(name, object.to_yaml)
        end

        define_method("#{name}_render") do
          send("#{name}_object").render
        end

        define_method("#{name}_edit") do
          send("#{name}_object").edit
        end
      end
    end
  end
end
