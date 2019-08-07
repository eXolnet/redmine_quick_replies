class Reply < ActiveRecord::Base
  include Redmine::SafeAttributes

  NAME_LENGTH_LIMIT = 60

  ## Attributes
  attr_protected :id, :user_id if ActiveRecord::VERSION::MAJOR <= 4
  attr_accessible :name, :body

  safe_attributes :name, :body

  ## Relations
  belongs_to :user

  ## Validations
  validates :user_id,   presence: true

  validates :name,      presence: true,
                        uniqueness: { case_sensitive: true, scope: :user_id },
                        length: { maximum: NAME_LENGTH_LIMIT }

  validates :body,      presence: true

  def visible?(user=User.current)
    self.user == user
  end
end
