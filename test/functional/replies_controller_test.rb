require File.expand_path('../../test_helper', __FILE__)

class RepliesControllerTest < ActionController::TestCase
  fixtures :users,
           :replies

  def setup
    @request.session[:user_id] = 1
  end

  def test_index
    get :index

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
      post :create, :reply => { :name => 'Quick Reply Name', :body => 'Body' }

      assert_response 302
      assert_redirected_to :controller => 'replies', :action => 'index'
    end

    assert User.current, reply.user
  end

  def test_create_reply_shoud_validate_required_fields_on_empty_post
    post :create

    assert_response :success

    assert_select_error(/Name cannot be blank/i)
    assert_select_error(/Reply cannot be blank/i)
  end

  def test_create_reply_shoud_validate_required_fields
    post :create, :reply => { :name => '', :body => '' }

    assert_response :success

    assert_select_error(/Name cannot be blank/i)
    assert_select_error(/Reply cannot be blank/i)
  end

  def test_edit_should_load_content
    get :edit, :id => 1

    assert_response :success

    assert_select 'input[type="text"][value="Name"]'
  end

  def test_edit_for_non_existing_reply
    get :edit, :id => 999

    assert_response 404
  end

  def test_edit_for_another_user_reply
    get :edit, :id => 2

    assert_response 403
  end

  def test_update_reply_with_valid_fields
    put :update, :id => 1, :reply => { :name => 'Quick Reply Name', :body => 'Body' }

    assert_response 302
    assert_redirected_to :controller => 'replies', :action => 'index'
  end

  def test_update_for_non_existing_reply
    put :update, :id => 999

    assert_response 404
  end

  def test_update_for_another_user_reply
    put :update, :id => 2

    assert_response 403
  end

  def test_update_reply_shoud_keep_reply_unchanged_on_empty_post
    put :update, :id => 1

    assert_response  302
    assert_redirected_to :controller => 'replies', :action => 'index'
  end

  def test_update_reply_shoud_validate_required_fields
    put :update, :id => 1, :reply => { :name => '', :body => '' }

    assert_response :success

    assert_select_error(/Name cannot be blank/i)
    assert_select_error(/Reply cannot be blank/i)
  end

  def test_destroy_reply
    delete :destroy, :id => 1

    assert_response  302
    assert_redirected_to :controller => 'replies', :action => 'index'
    assert ! Reply.find_by_id(1)
  end

  def test_destroy_for_non_existing_reply
    delete :destroy, :id => 999

    assert_response 404
  end

  def test_destroy_for_another_user_reply
    delete :destroy, :id => 2

    assert_response 403
  end
end
