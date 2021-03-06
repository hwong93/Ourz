class User < ActiveRecord::Base
  authenticates_with_sorcery!

  # attr_accessor :remote_image_url, :first_name, :last_name, :bio, :emaily, :profile_pic

  validates :password, length: { minimum: 3 }, if: -> { new_record? || changes[:crypted_password] }
  validates :password, confirmation: true, if: -> { new_record? || changes[:crypted_password] }
  validates :password_confirmation, presence: true, if: -> { new_record? || changes[:crypted_password] }

  validates :email, uniqueness: true

  has_many :posts, foreign_key: :author

  has_many :active_relationships,  class_name:  "Relationship",
                                   foreign_key: "follower_id",
                                   dependent:   :destroy
  has_many :passive_relationships, class_name:  "Relationship",
                                   foreign_key: "followed_id",
                                   dependent:   :destroy
  has_many :following, through: :active_relationships,  source: :followed
  has_many :followers, through: :passive_relationships, source: :follower

  has_many :comments
  has_many :comment_posts, through: :comments, source: 'post'

  has_many :likes
  has_many :like_posts, through: :likes, source: 'post'

  geocoded_by :full_street_address
  # after_validation :geocode, if: :address_changed?


  mount_uploader :profile_pic, ProfileUploader


  def following_posts(user)
    following_posts = []
    following_users = user.following

    following_users.each do |user|
      users_post = user.posts

      users_post.each do |post|
        following_posts << post
      end
    end
    return following_posts.sort_by(&:created_at)
  end




end
