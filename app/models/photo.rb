class Photo < ApplicationRecord
  belongs_to :user
  include ImageUploader::Attachment.new(:image)

  # :likers is the "initialised variable" from the joint table

  has_and_belongs_to_many :likers, class_name: 'User', join_table: :likes

  def liked_by? user
    # 1. likers -- relationship has_and_belongs_to_many
    # 2. exists? checks if there is a record with user
    # 3. user.id -- id of user we need to check
    likers.exists? user.id
  end

  def toggle_liked_by user
    if liked_by? user
      likers.destroy user
    else
      likers << user
    end

  end
end
