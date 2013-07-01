require 'test_helper'

class NewfeaturesControllerTest < ActionController::TestCase
  setup do
    @newfeature = newfeatures(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:newfeatures)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create newfeature" do
    assert_difference('Newfeature.count') do
      post :create, newfeature: { description: @newfeature.description, title: @newfeature.title }
    end

    assert_redirected_to newfeature_path(assigns(:newfeature))
  end

  test "should show newfeature" do
    get :show, id: @newfeature
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @newfeature
    assert_response :success
  end

  test "should update newfeature" do
    put :update, id: @newfeature, newfeature: { description: @newfeature.description, title: @newfeature.title }
    assert_redirected_to newfeature_path(assigns(:newfeature))
  end

  test "should destroy newfeature" do
    assert_difference('Newfeature.count', -1) do
      delete :destroy, id: @newfeature
    end

    assert_redirected_to newfeatures_path
  end
end
