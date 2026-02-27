class Article < ApplicationRecord
  belongs_to :author
  has_many :comments
  has_one :metadata
  has_and_belongs_to_many :tags

  belongs_to :category, class_name: 'Taxonomy::Category'
  has_many :published_articles, class_name: 'Article', foreign_key: 'author_id'
end

class Comment < ApplicationRecord
  belongs_to :article
  belongs_to :user
end

class User < ApplicationRecord
  has_many :articles
  has_many :comments

  has_one :profile
end
