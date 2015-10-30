ActiveAdmin.register <%= @scaffold.model_name %> do
  permit_params :content

  index do
    selectable_column
    column :created_at
    column :updated_at
    actions
  end

  form html: { class: "edit-atomic-content" } do |f|
    f.semantic_errors(*f.object.errors.keys)

    # new form
    if !f.object.persisted?
      f.inputs "Details" do
        # f.input :name
      end
      f.actions

    # edit form
    else
      div class: "buttons" do
        render partial: "admin/edit_buttons"
        f.actions
      end

      columns do
        column span: 3 do
          panel "Draft", id: "draft-panel" do
            render partial: "components/edit", locals: { f: f }
          end
        end

        column id: "edit-node-column" do
          div id: "edit-<%= @scaffold.model_file_name %>" do
            f.inputs "<%= @scaffold.model_name %> Details" do
              # f.input :name
            end
          end

          div id: "edit-node" do
            f.inputs "Edit Element" do
              div id: "edit-node-fields"
            end

            f.actions do
              li class: "move" do
                a "Up", "#", class: "button", id: "move-node-up"
              end
              li class: "move" do
                a "Down", "#", class: "button", id: "move-node-down"
              end
              li class: "cancel" do
                a "Done", "#", class: "button", id: "done-edit-node"
              end
              li class: "delete" do
                a "Delete", "#", class: "button", id: "delete-node"
              end
            end
          end
        end
      end
    end
  end

  show do
    div id: "component_preview" do
      div page.content_render
    end
  end

  controller do
    # permit all params until we can whitelist content_object
    def permitted_params
      params.permit!
    end
  end
end
