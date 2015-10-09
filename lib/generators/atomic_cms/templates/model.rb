class <%= @scaffold.model_name %> < ActiveRecord::Base
  include AtomicCms::HasComponents
  component_attr :content
end
