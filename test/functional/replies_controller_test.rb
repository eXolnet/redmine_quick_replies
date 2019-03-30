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
end
