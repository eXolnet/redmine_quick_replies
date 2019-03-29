require File.expand_path('../../test_helper', __FILE__)

class SkeletonControllerTest < ActionController::TestCase
  def test_index
    get :index

    assert_response 404
  end
end
