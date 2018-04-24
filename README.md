# Shrine Setup
## Initial Setup
```
rails new instarails_shrine
```
## Gemfile
```ruby
# Use shrine for file attachments
gem 'shrine', '~> 2.10', '>= 2.10.1'
# Use pundit for user authorisation
gem 'pundit', '~> 1.1'
# Use devise for user authentication
gem 'devise'

group :development, :test do
  gem 'rspec-rails', '~> 3.7', '>= 3.7.2'
  gem 'dotenv', '~> 2.3'
end
```
## Bundle
```
bundle i
```
Ensure all gems were added.
## Install devise, rspec & pundit
```
rails g devise:install

rails g rspec:install

rails g pundit:install
```
## Create User devise model
```
rails g devise User
```
## Create Photo scaffold
```
rails g scaffold Photo image_data:text user:references description:text
```
## Make folder 'uploaders' in app
Manually create file 'image_uploader.rb':
```ruby
class ImageUploader < Shrine
end
```
## Add virtual attribute to handle attachments to model
In model/photo.rb
```ruby
class Photo < ApplicationRecord
  belongs_to :user
  include ImageUploader::Attachment.new(:image) # adds an `image` virtual attribute
end
```
## Add relation with photos to User model
```ruby
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  
  has_many :photos
  
end
```
## Define current_user in Photos controller and authentication params
At top of photos_controller:
```ruby
  before_action :authenticate_user!, only: [:index, :show]
```
Under the create action:
```ruby
def create 
..code..

@photo.user = current_user

..code..
end
```
## Remove user_id params
views/photos/_form.html.erb -- remove fields for user_id
photos_controller -- remove user_id from photo_params
## Change image_data text field to file_field and add hidden_field
Also, change image_data to image in params
```html
<div class="field">
    <%= form.label :image_data %>
    <%= form.hidden_field :image, value: photo.cached_image_data %>
    <%= form.file_field :image, id: :photo_image_data %>
</div>
```
Sidenote for further reading: 'hidden_field' is for caching the image.

Under photos_controller:
```ruby
def photo_params
    params.require(:photo).permit(:image, :description)
end
```
## Under views/photos/show.html.erb
Change formatting of how image is displayed with 'image_url':
```html
<p>
  <strong>Image data:</strong>
  <img src="<%= @photo.image_url %>" alt="<%= @photo.description %>">
</p>
```
And display user as user id instead of the User object:
```html
<p>
  <strong>User:</strong>
  <%= @photo.user_id %>
</p>
```
## Challenge Time!
Create a grid card system to display uploaded photos

## Compress/Scale Images Uploaded
https://github.com/shrinerb/shrine#processing
Bundle the following after adding to GEMFILE:
```ruby
gem 'image_processing', '~> 1.2'
```
https://github.com/shrinerb/shrine#versions
Under models/uploaders/image_uploader.rb
```ruby
require "image_processing/mini_magick"

class ImageUploader < Shrine
    plugin :processing
    plugin :versions, names: [:original, :thumb, :medium]   # enable Shrine to handle a hash of files
    plugin :delete_raw # delete processed files after uploading

    process(:store) do |io, context|
        original = io.download
        pipeline = ImageProcessing::MiniMagick.source(original)
        size_80 = pipeline.resize_to_limit!(80, 80)
        size_300 = pipeline.resize_to_limit!(300, 300)

        original.close! # clears the original out of RAM memory once processed.
        { original: io, medium: size_300, thumb: size_80 }
    end
end
```

## Working on a Likes feature
```
rails g migration CreateJoinTableLikes user photo
```
Check migration file and set table name
```ruby
class CreateJoinTableLikes < ActiveRecord::Migration[5.1]
  def change
    create_join_table :users, :photos, table_name: :likes do |t| # table_name is to specify the tablename otherwise Rails default would be 'UserstoPhotos'
      t.index [:user_id, :photo_id]
      t.index [:photo_id, :user_id]
    end
  end
end
```
```
rails db:migrate
```
Should see the table pop up in schema.

## Add liked_by? check function to photo model
```ruby
class Photo < ApplicationRecord
  belongs_to :user
  include ImageUploader::Attachment.new(:image)
  
  has_and_belongs_to_many :likers, class_name: 'User', join_table: :likes

  def liked_by? user
    # 1. likers -- relationship has_and_belongs_to_many
    # 2. exists? checks if there is a record with user
    # 3. user.id -- id of user we need to check
    likers.exists? user.id
  end
end
```

## Add the 'Liking' feature to photo model
```ruby
class Photo < ApplicationRecord
  # codeblablablabla

  def toggle_liked_by user
    if liked_by? user
      likers.destroy user
    else
      likers << user
    end
end
```
If the photo has already been liked by the same user, 'unlikes' the photo.
Otherwise, will 'like' the photo by the user.


