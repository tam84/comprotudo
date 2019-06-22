class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  #has_many :message_members
  #has_many :email_messages
  has_many :products

  has_many_attached :profile_photos


  has_many :notifications

  has_many :posts, as: :postable

  has_many_attached :documents

  has_many :connections

  has_many :profiles

  has_many :products





#  include PgSearch
#  pg_search_scope :search_by_full_name, against: [:full_name]



  def name
  	email.split('@')[0]
  end

  def thumbnail input
    return self.avatars[input].variant(resize: '300x300!').processed
  end


  def firm_name user
    firm_name = user.firm.name
  end

  def to_param
    "#{id}-#{name}".parameterize
  end  


  #def active_for_authentication? 
  #  super && approved? 
  #end 
  
  def inactive_message 
    approved? ? super : :not_approved
  end    

end
