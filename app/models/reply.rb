class Reply < ActiveRecord::Base
  include Redmine::SafeAttributes

  NAME_LENGTH_LIMIT = 60

  ## Attributes
  attr_protected :id, :user_id if ActiveRecord::VERSION::MAJOR <= 4

  safe_attributes :name, :body

  safe_attributes :is_public, :if => lambda {|reply, user| user.allowed_to_manage_public_replies?}

  ## Relations
  belongs_to :user

  ## Validations
  validates :user_id,   presence: true

  validates :name,      presence: true,
                        uniqueness: { case_sensitive: true, scope: :user_id },
                        length: { maximum: NAME_LENGTH_LIMIT }

  validates :body,      presence: true

  ## Scopes
  scope :all_public, lambda { where(:is_public => true) }

  scope :author, lambda {|*args|
    user = args.first || User.current

    where(:user_id => user.id)
  }
  
  scope :editable, lambda {|*args|
    user = args.first || User.current

    return visible if user.allowed_to_manage_public_replies?

    author(user)
  }

  scope :sorted, lambda { order(:name, :id) }

  scope :visible, lambda {|*args|
    user = args.first || User.current

    where("(#{table_name}.is_public=1 OR #{table_name}.user_id = #{user.id})")
  }

  def author?(user=User.current)
    self.user == user
  end

  def editable?(user=User.current)
    author?(user) || (is_public? && user.allowed_to_manage_public_replies?)
  end

  def is_private?
    !is_public?
  end

  def is_public?
    is_public
  end

  def visible?(user=User.current)
    is_public? || author?(user)
  end
end
