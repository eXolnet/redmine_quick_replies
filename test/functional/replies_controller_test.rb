require File.expand_path('../../test_helper', __FILE__)

class RepliesControllerTest < ActionController::TestCase
  fixtures :users,
           :email_addresses,
           :projects,
           :roles,
           :members,
           :member_roles,
           :replies

  def setup
    @request.session[:user_id] = 1
  end

  def test_index
    compatible_request :get, :index

    assert_response :success

    assert_select 'table.replies' do
      assert_select 'tbody tr' do
        assert_select 'a[href="/my/replies/1/edit"]'
        assert_select 'a[href="/my/replies/1"][data-method="delete"]'
      end

      assert_select 'a[href="/my/replies/2"]', 0
    end
  end

  def test_index_loads_quick_replies_in_wiki_editor
    compatible_request :get, :index

    assert_response :success

    assert_select 'script[src*="/plugin_assets/redmine_quick_replies"]'
    assert_select 'link[href*="/plugin_assets/redmine_quick_replies"]'
  end

  def test_index_should_redirect_anonymous_to_login
    @request.session[:user_id] = nil

    compatible_request :get, :index

    assert_response 302
    assert_match %r{/login\?back_url=}, response.location
  end

  def test_index_without_create_replies_permission
    @request.session[:user_id] = 2

    compatible_request :get, :index

    assert_response 403
  end

  def test_index_with_create_replies_permission_lists_only_own_replies
    Role.find(1).add_permission! :create_replies
    @request.session[:user_id] = 2

    compatible_request :get, :index

    assert_response :success
    assert_select 'table.replies tbody tr', 1
    assert_select 'a[href="/my/replies/2/edit"]'
    assert_select 'a[href="/my/replies/3/edit"]', 0
    assert_select 'input[name="reply[is_public]"]', 0
  end

  def test_index_with_manage_public_replies_permission_lists_public_replies_of_others
    Role.find(1).add_permission! :create_replies, :manage_public_replies
    @request.session[:user_id] = 2

    compatible_request :get, :index

    assert_response :success
    assert_select 'table.replies tbody tr', 2
    assert_select 'a[href="/my/replies/2/edit"]'
    assert_select 'a[href="/my/replies/3/edit"]'
    assert_select 'a[href="/my/replies/1/edit"]', 0
    assert_select 'input[name="reply[is_public]"]'
  end

  def test_index_wiki_editor_replies_should_only_contain_visible_replies
    Role.find(1).add_permission! :create_replies
    @request.session[:user_id] = 2

    compatible_request :get, :index

    assert_response :success
    assert_equal [2, 3], wiki_editor_replies.map { |reply| reply['id'] }
    assert_not_include 'Dapibus ligula phasellus', response.body
  end

  def test_create_reply_with_valid_fields
    reply = new_record(Reply) do
      compatible_request :post, :create, :reply => { :name => 'Quick Reply Name', :body => 'Body' }

      assert_response 302
      assert_redirected_to :controller => 'replies', :action => 'index'
    end

    assert_equal User.find(1), reply.user
    assert_equal 'Quick Reply Name', reply.name
    assert_equal 'Body', reply.body
    assert_equal false, reply.is_public?
    assert_equal 'Quick reply successfully created.', flash[:notice]
  end

  def test_create_reply_public
    reply = new_record(Reply) do
      compatible_request :post, :create, :reply => { :name => 'Quick Reply Name', :is_public => '1', :body => 'Body' }

      assert_response 302
      assert_redirected_to :controller => 'replies', :action => 'index'
    end

    assert_equal User.find(1), reply.user
    assert_equal true, reply.is_public?
  end

  def test_create_reply_should_validate_required_fields_on_empty_post
    compatible_request :post, :create

    assert_response :success

    assert_select_error(/Name cannot be blank/i)
    assert_select_error(/Reply cannot be blank/i)
  end

  def test_create_reply_should_validate_required_fields
    compatible_request :post, :create, :reply => { :name => '', :body => '' }

    assert_response :success

    assert_select_error(/Name cannot be blank/i)
    assert_select_error(/Reply cannot be blank/i)
  end

  def test_create_reply_should_validate_name_uniqueness
    assert_no_difference 'Reply.count' do
      compatible_request :post, :create, :reply => { :name => 'Reply 1', :body => 'Body' }
    end

    assert_response :success
    assert_select_error(/Name has already been taken/i)
  end

  def test_create_without_create_replies_permission
    @request.session[:user_id] = 2

    assert_no_difference 'Reply.count' do
      compatible_request :post, :create, :reply => { :name => 'Quick Reply Name', :is_public => '1', :body => 'Body' }
    end

    assert_response 403
  end

  def test_create_public_reply_without_manage_public_permission_should_ignore_is_public
    Role.find(1).add_permission! :create_replies
    @request.session[:user_id] = 2

    reply = new_record(Reply) do
      compatible_request :post, :create, :reply => { :name => 'Quick Reply Name', :is_public => '1', :body => 'Body' }

      assert_redirected_to :controller => 'replies', :action => 'index'
    end

    assert_equal User.find(2), reply.user
    assert_equal false, reply.is_public?
  end

  def test_create_public_reply_with_manage_public_permission
    Role.find(1).add_permission! :create_replies, :manage_public_replies
    @request.session[:user_id] = 2

    reply = new_record(Reply) do
      compatible_request :post, :create, :reply => { :name => 'Quick Reply Name', :is_public => '1', :body => 'Body' }

      assert_redirected_to :controller => 'replies', :action => 'index'
    end

    assert_equal User.find(2), reply.user
    assert_equal true, reply.is_public?
  end

  def test_preview
    with_settings :text_formatting => 'textile' do
      compatible_request :post, :preview, :reply => { :body => 'Some *preview* text' }
    end

    assert_response :success
    assert_select 'fieldset.preview' do
      assert_select 'legend', :text => 'Reply'
      assert_select 'strong', :text => 'preview'
    end
  end

  def test_preview_without_body
    compatible_request :post, :preview

    assert_response :success
    assert_select 'fieldset.preview', 0
  end

  def test_preview_without_create_replies_permission
    @request.session[:user_id] = 2

    compatible_request :post, :preview, :reply => { :body => 'Some text' }

    assert_response 403
  end

  def test_edit_should_load_content
    compatible_request :get, :edit, :id => 1

    assert_response :success

    assert_select 'input[type="text"][value="Reply 1"]'
    assert_select 'textarea#reply_body', :text => 'Dapibus ligula phasellus'
  end

  def test_edit_for_non_existing_reply
    compatible_request :get, :edit, :id => 999

    assert_response 404
  end

  def test_edit_for_another_user_reply
    compatible_request :get, :edit, :id => 2

    assert_response 403
  end

  def test_edit_another_user_public_reply_without_manage_public_permission
    Role.find(1).add_permission! :create_replies
    @request.session[:user_id] = 2

    compatible_request :get, :edit, :id => 3

    assert_response 403
  end

  def test_edit_another_user_public_reply_with_manage_public_permission
    Role.find(1).add_permission! :create_replies, :manage_public_replies
    @request.session[:user_id] = 2

    compatible_request :get, :edit, :id => 3

    assert_response :success
    assert_select 'input[type="text"][value="Reply 3"]'
  end

  def test_edit_another_user_private_reply_with_manage_public_permission
    Role.find(1).add_permission! :create_replies, :manage_public_replies
    @request.session[:user_id] = 2

    compatible_request :get, :edit, :id => 1

    assert_response 403
  end

  def test_update_reply_with_valid_fields
    compatible_request :put, :update, :id => 1, :reply => { :name => 'Quick Reply Name', :body => 'Body' }

    assert_response 302
    assert_redirected_to :controller => 'replies', :action => 'index'
    assert_equal 'Quick reply successfully updated.', flash[:notice]

    reply = Reply.find(1)
    assert_equal 'Quick Reply Name', reply.name
    assert_equal 'Body', reply.body
    assert_equal 1, reply.user_id
  end

  def test_update_for_non_existing_reply
    compatible_request :put, :update, :id => 999

    assert_response 404
  end

  def test_update_for_another_user_reply
    compatible_request :put, :update, :id => 2, :reply => { :name => 'Hijacked' }

    assert_response 403
    assert_equal 'Reply 2', Reply.find(2).name
  end

  def test_update_reply_should_keep_reply_unchanged_on_empty_post
    compatible_request :put, :update, :id => 1

    assert_response  302
    assert_redirected_to :controller => 'replies', :action => 'index'

    reply = Reply.find(1)
    assert_equal 'Reply 1', reply.name
    assert_equal 'Dapibus ligula phasellus', reply.body
  end

  def test_update_reply_should_validate_required_fields
    compatible_request :put, :update, :id => 1, :reply => { :name => '', :body => '' }

    assert_response :success

    assert_select_error(/Name cannot be blank/i)
    assert_select_error(/Reply cannot be blank/i)
    assert_equal 'Reply 1', Reply.find(1).name
  end

  def test_update_without_create_replies_permission
    @request.session[:user_id] = 2

    compatible_request :put, :update, :id => 1, :reply => { :name => 'Quick Reply Name', :is_public => '1', :body => 'Body' }

    assert_response 403
    assert_equal 'Reply 1', Reply.find(1).name
  end

  def test_update_public_flag_without_manage_public_permission_should_be_ignored
    Role.find(1).add_permission! :create_replies
    @request.session[:user_id] = 2

    compatible_request :put, :update, :id => 2, :reply => { :name => 'Renamed', :is_public => '1' }

    assert_redirected_to :controller => 'replies', :action => 'index'

    reply = Reply.find(2)
    assert_equal 'Renamed', reply.name
    assert_equal false, reply.is_public?
  end

  def test_update_another_user_public_reply_with_manage_public_permission
    Role.find(1).add_permission! :create_replies, :manage_public_replies
    @request.session[:user_id] = 2

    compatible_request :put, :update, :id => 3, :reply => { :body => 'Updated body', :is_public => '0' }

    assert_redirected_to :controller => 'replies', :action => 'index'

    reply = Reply.find(3)
    assert_equal 'Updated body', reply.body
    assert_equal false, reply.is_public?
    assert_equal 1, reply.user_id
  end

  def test_destroy_reply
    compatible_request :delete, :destroy, :id => 1

    assert_response  302
    assert_redirected_to :controller => 'replies', :action => 'index'
    assert_equal 'Quick reply successfully deleted.', flash[:notice]
    assert_nil Reply.find_by_id(1)
  end

  def test_destroy_for_non_existing_reply
    compatible_request :delete, :destroy, :id => 999

    assert_response 404
  end

  def test_destroy_for_another_user_reply
    compatible_request :delete, :destroy, :id => 2

    assert_response 403
    assert Reply.exists?(2)
  end

  def test_destroy_another_user_public_reply_without_manage_public_permission
    Role.find(1).add_permission! :create_replies
    @request.session[:user_id] = 2

    compatible_request :delete, :destroy, :id => 3

    assert_response 403
    assert Reply.exists?(3)
  end

  private

  def wiki_editor_replies
    json = response.body[/redmine_quick_replies = (\[.*\]);/, 1]
    assert_not_nil json, 'quick replies are not loaded in the wiki editor'

    JSON.parse(json)
  end
end
