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
  end

  def test_create_reply
    assert_difference 'Reply.count' do
      post :create, :reply => { :name => 'Quick Reply Name', :body => 'Body' }

      assert_response 302
    end

    reply = Reply.last
    assert_kind_of Reply, reply
  end
end
