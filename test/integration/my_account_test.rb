require File.expand_path('../../test_helper', __FILE__)

class MyAccountTest < Redmine::IntegrationTest
  fixtures :users,
           :email_addresses,
           :user_preferences,
           :projects,
           :roles,
           :members,
           :member_roles

  def test_my_account_should_show_quick_replies_link_with_create_replies_permission
    Role.find(1).add_permission! :create_replies
    log_user('jsmith', 'jsmith')

    get '/my/account'

    assert_response :success
    assert_select '#content .contextual a.icon-comment[href="/my/replies"]', :text => /Quick replies/
  end

  def test_my_account_should_not_show_quick_replies_link_without_create_replies_permission
    log_user('jsmith', 'jsmith')

    get '/my/account'

    assert_response :success
    assert_select 'a[href="/my/replies"]', 0
  end
end
