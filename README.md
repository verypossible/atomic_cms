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
gem 'atomic_cms', github: 'verypossible/atomic_cms'
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
bundle exec rake db:create
bundle exec rake db:migrate
```
To verify, start the server and visit `localhost:3000/admin`. If you can login
as `admin@example.com` with the password `password` you have successfully
completed this step.

### Atomic CMS
#### Routes
Update your `config/routes.rb` to include the following:
```ruby
mount AtomicCms::Engine => "/atomic_cms", as: :atomic_cms
# If you are going to use a catch all route add the following line
get "*path", to: "pages#show", controller: "pages", as: :page, format: false
root to: 'pages#show', controller: "pages"
```
The last two lines need to be at the **END** of your `routes.rb` file.

##### Devise Authentication
Change the mount point above to be the following:
```ruby
  authenticate :admin_user, -> (u) { u.admin? } do
    mount AtomicCms::Engine => "/atomic_cms", as: :atomic_cms
  end
```
where `u` is the user and `admin?` the authentication method you have on that
user; it should return a boolean value.

#### Scaffold Generator
Execute the following to create a model for your static pages:
```ruby
rails g atomic_cms:scaffold page
```
*After this you should run your migrations.*

Here is a list of everything that is generated for you:

* Model
* Controller
* Active Admin Form
* Migration **Will need to be edited**
* Show View
* Route

### Media Upload
To install the media tables so that you can upload files until your heart is
literally full run:
```
rake atomic_cms:install:migrations
rake db:migrate
```
Also, you should configure paperclip to use s3, since s3 is better than local
file storage.
```ruby
class Application < Rails::Application
  ...
  config.paperclip_defaults = {
    storage: :s3,
    s3_protocol: "https",
    s3_credentials: {
      bucket: ENV.fetch("AWS_S3_BUCKET", ""),
      access_key_id: ENV.fetch("AWS_ACCESS_KEY", ""),
      secret_access_key: ENV.fetch("AWS_SECRET", ""),
      s3_region: ENV.fetch("AWS_REGION", ""),
    }
  }
  ...
end
```

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
*NOTE:* At the minimum, here is what is needed in `active_admin.scss`:
```scss
@import "active_admin/mixins";
@import "active_admin/base";
@import "atomic_cms";

#component_preview {
  // Include application specific styling here
}
```

#### Components
Generate components by executing the following:
```
rails g atomic_assets:component text_block
```
In order for components to be utilized when managing content, a partial needs to
be created similar to the following at `app/views/admin/_edit_buttons.html.slim`:
```slim
ol.edit-buttons
  li
    = link_to 'Text Block', atomic_cms.edit_component_path('text_block'), class: 'button'
```
#### Config
Update `config/application.rb` to include:
```ruby
config.autoload_paths += %W(#{config.root}/lib, #{config.root}/app/components/**/)
```
### Gotcha's
When creating a path for a page, from the examples above, make sure to include a
leading '/', for example: '/home' -or- '/bears'

## License
Atomic CMS is released under the [MIT License](http://opensource.org/licenses/MIT).
