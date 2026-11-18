require File.expand_path('../../test_helper', __FILE__)

class ReplyTest < ActiveSupport::TestCase
  fixtures :users,
           :projects,
           :roles,
           :members,
           :member_roles,
           :replies

  def setup
    User.current = nil
  end

  def test_create
    reply = Reply.new(:user => User.find(2), :name => 'New reply', :body => 'Body')

    assert reply.save
    assert_equal false, reply.reload.is_public?
  end

  def test_should_require_user_name_and_body
    reply = Reply.new

    assert_not reply.valid?
    assert_include :user_id, reply.errors.attribute_names
    assert_include :name, reply.errors.attribute_names
    assert_include :body, reply.errors.attribute_names
  end

  def test_name_should_be_unique_per_user
    reply = Reply.new(:user => User.find(1), :name => 'Reply 1', :body => 'Body')

    assert_not reply.valid?
    assert_include :name, reply.errors.attribute_names
  end

  def test_name_uniqueness_should_be_case_sensitive
    reply = Reply.new(:user => User.find(1), :name => 'REPLY 1', :body => 'Body')

    assert reply.valid?
  end

  def test_same_name_should_be_allowed_for_another_user
    reply = Reply.new(:user => User.find(2), :name => 'Reply 1', :body => 'Body')

    assert reply.valid?
  end

  def test_name_length_limit
    reply = Reply.new(:user => User.find(1), :body => 'Body')

    reply.name = 'a' * Reply::NAME_LENGTH_LIMIT
    assert reply.valid?

    reply.name = 'a' * (Reply::NAME_LENGTH_LIMIT + 1)
    assert_not reply.valid?
    assert_include :name, reply.errors.attribute_names
  end

  def test_safe_attributes_should_ignore_is_public_without_manage_public_permission
    Role.find(1).add_permission! :create_replies
    reply = Reply.new

    reply.send :safe_attributes=, { 'name' => 'Name', 'body' => 'Body', 'is_public' => '1' }, User.find(2)

    assert_equal 'Name', reply.name
    assert_equal 'Body', reply.body
    assert_equal false, reply.is_public?
  end

  def test_safe_attributes_should_accept_is_public_with_manage_public_permission
    Role.find(1).add_permission! :manage_public_replies
    reply = Reply.new

    reply.send :safe_attributes=, { 'name' => 'Name', 'is_public' => '1' }, User.find(2)

    assert_equal true, reply.is_public?
  end

  def test_all_public_scope
    assert_equal [3], Reply.all_public.pluck(:id)
  end

  def test_author_scope
    assert_equal [1, 3], Reply.author(User.find(1)).order(:id).pluck(:id)
    assert_equal [2], Reply.author(User.find(2)).pluck(:id)
  end

  def test_author_scope_should_default_to_current_user
    User.current = User.find(2)

    assert_equal [2], Reply.author.pluck(:id)
  end

  def test_visible_scope
    assert_equal [1, 3], Reply.visible(User.find(1)).order(:id).pluck(:id)
    assert_equal [2, 3], Reply.visible(User.find(2)).order(:id).pluck(:id)
    assert_equal [3], Reply.visible(User.find(3)).pluck(:id)
  end

  def test_visible_scope_should_default_to_current_user
    User.current = User.find(2)

    assert_equal [2, 3], Reply.visible.order(:id).pluck(:id)
  end

  def test_editable_scope_without_manage_public_permission
    assert_equal [2], Reply.editable(User.find(2)).pluck(:id)
  end

  def test_editable_scope_with_manage_public_permission
    Role.find(1).add_permission! :manage_public_replies

    assert_equal [2, 3], Reply.editable(User.find(2)).order(:id).pluck(:id)
  end

  def test_editable_scope_should_default_to_current_user
    User.current = User.find(2)

    assert_equal [2], Reply.editable.pluck(:id)
  end

  def test_sorted_scope
    Reply.create!(:user => User.find(1), :name => 'A reply', :body => 'Body')

    assert_equal ['A reply', 'Reply 1', 'Reply 3'], Reply.author(User.find(1)).sorted.map(&:name)
  end

  def test_author
    reply = Reply.find(1)

    assert reply.author?(User.find(1))
    assert_not reply.author?(User.find(2))
  end

  def test_author_should_default_to_current_user
    User.current = User.find(1)

    assert Reply.find(1).author?
    assert_not Reply.find(2).author?
  end

  def test_visible
    user = User.find(2)

    assert_not Reply.find(1).visible?(user)
    assert Reply.find(2).visible?(user)
    assert Reply.find(3).visible?(user)
  end

  def test_visible_should_default_to_current_user
    User.current = User.find(2)

    assert_not Reply.find(1).visible?
    assert Reply.find(3).visible?
  end

  def test_editable_without_manage_public_permission
    user = User.find(2)

    assert_not Reply.find(1).editable?(user)
    assert Reply.find(2).editable?(user)
    assert_not Reply.find(3).editable?(user)
  end

  def test_editable_with_manage_public_permission
    Role.find(1).add_permission! :manage_public_replies
    user = User.find(2)

    assert_not Reply.find(1).editable?(user)
    assert Reply.find(2).editable?(user)
    assert Reply.find(3).editable?(user)
  end

  def test_editable_should_default_to_current_user
    User.current = User.find(2)

    assert Reply.find(2).editable?
    assert_not Reply.find(1).editable?
  end

  def test_is_public_and_is_private
    assert_equal false, Reply.find(1).is_public?
    assert_equal true, Reply.find(1).is_private?
    assert_equal true, Reply.find(3).is_public?
    assert_equal false, Reply.find(3).is_private?
  end
end
