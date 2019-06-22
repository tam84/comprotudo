class Firm < ApplicationRecord
  has_many_attached :firm_photos
  has_many :products
  has_many :posts, as: :postable
  has_many_attached :documents
  has_many_attached :releases
  has_many_attached :videos
  has_many :youtube_videos, as: :videoable



#  include PgSearch
#  pg_search_scope :search_by_name, against: [:name]


  def thumbnail input
    return self.avatars[input].variant(resize: '300x300!').processed
  end

end







