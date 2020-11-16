require File.expand_path('../../test_helper', __FILE__)

class RepliesControllerTest < ActionController::TestCase
  fixtures :users,
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

  def test_create_reply_with_valid_fields
    reply = new_record(Reply) do
      compatible_request :post, :create, :reply => { :name => 'Quick Reply Name', :body => 'Body' }

      assert_response 302
      assert_redirected_to :controller => 'replies', :action => 'index'
    end

    assert User.current, reply.user
  end

  def test_create_reply_public
    reply = new_record(Reply) do
      compatible_request :post, :create, :reply => { :name => 'Quick Reply Name', :is_public => '1', :body => 'Body' }

      assert_response 302
      assert_redirected_to :controller => 'replies', :action => 'index'
    end

    assert User.current, reply.user
    assert true, reply.is_public
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

  def test_create_reply_without_manage_public_permission
    @request.session[:user_id] = 2

    compatible_request :post, :create, :reply => { :name => 'Quick Reply Name', :is_public => '1', :body => 'Body' }

    assert_response 403
  end

  def test_edit_should_load_content
    compatible_request :get, :edit, :id => 1

    assert_response :success

    assert_select 'input[type="text"][value="Name"]'
  end

  def test_edit_for_non_existing_reply
    compatible_request :get, :edit, :id => 999

    assert_response 404
  end

  def test_edit_for_another_user_reply
    compatible_request :get, :edit, :id => 2

    assert_response 403
  end

  def test_update_reply_with_valid_fields
    compatible_request :put, :update, :id => 1, :reply => { :name => 'Quick Reply Name', :body => 'Body' }

    assert_response 302
    assert_redirected_to :controller => 'replies', :action => 'index'
  end

  def test_update_for_non_existing_reply
    compatible_request :put, :update, :id => 999

    assert_response 404
  end

  def test_update_for_another_user_reply
    compatible_request :put, :update, :id => 2

    assert_response 403
  end

  def test_update_reply_should_keep_reply_unchanged_on_empty_post
    compatible_request :put, :update, :id => 1

    assert_response  302
    assert_redirected_to :controller => 'replies', :action => 'index'
  end

  def test_update_reply_should_validate_required_fields
    compatible_request :put, :update, :id => 1, :reply => { :name => '', :body => '' }

    assert_response :success

    assert_select_error(/Name cannot be blank/i)
    assert_select_error(/Reply cannot be blank/i)
  end

  def test_update_without_manage_public_permission
    @request.session[:user_id] = 2

    compatible_request :put, :update, :id => 1, :reply => { :name => 'Quick Reply Name', :is_public => '1', :body => 'Body' }

    assert_response 403
  end

  def test_destroy_reply
    compatible_request :delete, :destroy, :id => 1

    assert_response  302
    assert_redirected_to :controller => 'replies', :action => 'index'
    assert ! Reply.find_by_id(1)
  end

  def test_destroy_for_non_existing_reply
    compatible_request :delete, :destroy, :id => 999

    assert_response 404
  end

  def test_destroy_for_another_user_reply
    compatible_request :delete, :destroy, :id => 2

    assert_response 403
  end
end
