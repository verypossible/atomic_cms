# Atomic CMS
The biggest problem with any content management system is the admin users are
given too much or too little power when editing their site. This gem provides a
means to manage usage of components created from the gem Atomic Assets. By
providing admin users with a way to manage their Atomic Assets, developers and
designers are able to ensure the components they create remained styled properly
while allowing admins to update their content as needed without developer
intervention. Below are instructions for getting started.

## Gemfile
After initializing a new Rails application, or adding to an existing
application, add the following gems to your Gemfile.
```ruby
gem 'atomic_cms', github: 'spartansystems/atomic_cms'
gem 'devise'
```
_Note: devise is optional if you do not want admin users to login._

Then perform a `bundle install`.

## Initialization
### Active Admin
To initialize Active Admin:
```ruby
rails generate atomic_cms:install
```
Remove the comments migration Active Admin created along with disabling comments
on line 122 of the Active Admin initializer.

Now you shall run the migration and seeds with:
```ruby
bundle exec rake db:setup
```
To verify, start the server and visit `localhost:3000/admin`. If you can login
as `admin@example.com` with the password `password` you have successfully
completed this step.

#### Styles
In order for component previews to have the proper project styling,
`active_admin.scss` will need to be updated to import your `application.scss`.
*NOTE:* If you are using bourbon, bitters, and neat you will not be able to
straight import `application.scss` as certain styles within base must be
imported under the `#component_preview` selector. Below is an example of how
this is properly imported:

```scss
@import "active_admin/mixins";
@import "active_admin/base";
@import "bourbon";
@import "neat";
@import "base/variables";
@import "base/grid-settings";
@import "atomic_cms";

#component_preview {
  @import "reset";
  @import "base/buttons";
  @import "base/forms";
  @import "base/lists";
  @import "base/tables";
  @import "base/typography";
  @import "components/*";
  @include font-feature-settings("kern", "liga", "pnum");
  -webkit-font-smoothing: antialiased;
  color: $base-font-color;
  font-family: $base-font-family;
  font-size: 16px;
  line-height: $base-line-height;
  // When editing a page through the CMS,
  // images with broken links will not be displayed
  img[src="image"] {
    display: none !important;
  }
}

// Overriding any non-variable SASS must be done after the fact.
// For example, to change the default status-tag color:
//
//   .status_tag { background: #6090DB; }
```

### Atomic CMS
#### Routes
Update your `config/routes.rb` to include the following:
```ruby
mount AtomicCms::Engine => "/atomic_cms"
get "*path", to: "pages#show", controller: "pages", as: :page, format: false
root to: 'pages#show', controller: "pages"
```
The last two lines need to be at the **END** of your `routes.rb` file.
#### Model
Execute the following to create a model for your static pages:
```ruby
rails g model pages title:string path:string content:text
```
After this you should run your migrations.

Update your Page model to match the following:
```ruby
class Page < ActiveRecord::Base
  include AtomicCms::HasComponents
  validates :title, :path, presence: true, uniqueness: true
  component_attr :content
end
```
#### Controller
Create a controller by running the following:
```ruby
rails g controller pages
```
Update your PagesController to match the following:
```ruby
require 'json'

class PagesController < ApplicationController
  def show
    @page = Page.find_by_path(request.path)
    if @page
      render cms_template
    else
      render file: "#{Rails.root}/public/404.html", status: :not_found
      Rails.logger.error "404 - Page #{request.path} cannot be found."
    end
  end

  private

  def cms_template
    File.join("pages", "page")
  end
end
```
#### Helper
Create `app/helpers/application_helper.rb` and update it to match the following:
```ruby
module ApplicationHelper
  def add_option(option, output = nil)
    return unless option
    return output if output
    option
  end

  def markdown(text)
    return unless text
    Redcarpet::Markdown.new(Redcarpet::Render::HTML).render(text).html_safe
  end

  def markdown_help_url
    "http://nestacms.com/docs/creating-content/markdown-cheat-sheet"
  end
end
```
#### Views
Create a view at `app/views/pages/page.html.slim` that contains the following:
```ruby
= @page.content_object.render
```
#### Components
Create the following component view at
`app/views/components/text_block.html.slim`:
```slim
.wrapper.large-margin
  .text-block
    .content-text
      - if add_option(options[:header])
        h2
          = options[:header]
      = markdown(options[:content])
```
Create the following component class at `app/components/text_block_component.rb`:
```ruby
class TextBlockComponent < AtomicAssets::Component
  def edit
    rtn = cms_fields(field_types)
    rtn << h.component(:text_block, field_previews).render
    rtn.html_safe
  end

  protected

  def field_previews
    {
      header: "{{preview.header}}",
      content: markdown_preview('preview.content')
    }
  end

  def field_types
    {
      header: { field_type: "text" },
      content: { field_type: "markdown" }
    }
  end
end
```
Add the following to `app/assets/stylesheets/components/_text_block.scss`:
```scss
.text-block{
  position: relative;
  .content-text{
    ul{
      margin-left: 10px;
      padding-left: 0px;
      position: relative;
      display: inline-block;
      li{
        list-style: disc;
        margin-left: 20px;
      }
    }
  }
  &:before {
    content: '';
    display: inline-block;
    height: 100%;
    vertical-align: middle;
    margin-right: -0.25em; /* Adjusts for spacing */
  }
}
```
### More Active Admin
In order to add components to a page, create
`app/views/admin/_edit_buttons.html.slim` and make it match the following:
```slim
ol.edit-buttons
  li
    = link_to 'Text Block', atomic_cms.edit_component_path('text_block'), class: 'button'
```
Create an admin page for the Pages model at `app/admin/page.rb` and make it
match the following:
```ruby
ActiveAdmin.register Page do
  permit_params :title, :path, :content

  index do
    selectable_column
    column :path
    column :title
    column :created_at
    column :updated_at
    actions
  end

  form do |f|
    f.semantic_errors(*f.object.errors.keys)

    # new form
    if !f.object.persisted?
      f.inputs 'Page Details' do
        f.input :title
        f.input :path
      end
      f.actions

    # edit form
    else
      div class: 'buttons' do
        render partial: 'admin/edit_buttons'
        f.actions
      end

      columns do
        column span: 3 do
          panel 'Draft', id: 'draft-panel' do
            render partial: 'components/edit', locals: { f: f }
          end
        end

        column id: 'edit-node-column' do
          div id: 'edit-page' do
            f.inputs 'Page Details' do
              f.input :title
              f.input :path
            end
          end

          div id: 'edit-node' do
            f.inputs 'Edit Element' do
              div id: 'edit-node-fields'
            end

            f.actions do
              li class: 'move' do
                a 'Up', '#', class: 'button', id: 'move-node-up'
              end
              li class: 'move' do
                a 'Down', '#', class: 'button', id: 'move-node-down'
              end
              li class: 'cancel' do
                a 'Done', '#', class: 'button', id: 'done-edit-node'
              end
              li class: 'delete' do
                a 'Delete', '#', class: 'button', id: 'delete-node'
              end
            end
          end
        end
      end
    end
  end

  show do
    div id: 'component_preview' do
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
```
#### Config
Update `config/application.rb` to include:
```ruby
config.autoload_paths += %W(#{config.root}/lib, #{config.root}/app/components/**/)
```

#### Devise Auth
If you want devise authentication
Update `config/routes.rb` to include:

### Gotcha's
When creating a path for a page, from the examples above, make sure to include a
leading '/', for example: '/home' -or- '/bears'
