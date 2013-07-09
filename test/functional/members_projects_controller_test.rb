require 'test_helper'

class MembersProjectsControllerTest < ActionController::TestCase
  setup do
    @members_project = members_projects(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:members_projects)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create members_project" do
    assert_difference('MembersProject.count') do
      post :create, members_project: { position: @members_project.position, project_id: @members_project.project_id, user_id: @members_project.user_id }
    end

    assert_redirected_to members_project_path(assigns(:members_project))
  end

  test "should show members_project" do
    get :show, id: @members_project
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @members_project
    assert_response :success
  end

  test "should update members_project" do
    put :update, id: @members_project, members_project: { position: @members_project.position, project_id: @members_project.project_id, user_id: @members_project.user_id }
    assert_redirected_to members_project_path(assigns(:members_project))
  end

  test "should destroy members_project" do
    assert_difference('MembersProject.count', -1) do
      delete :destroy, id: @members_project
    end

    assert_redirected_to members_projects_path
  end
end
