require "test_helper"

class CreateTrainerTest < ActionDispatch::IntegrationTest
  setup do
    @admin_user = User.create(username: "johndoe", email: "johndoe@example.com",
                              password: "password", admin: true)
    sign_in_as(@admin_user)
  end

  test "get new trainer form and create trainer" do
    get "/trainers/new"
    assert_response :success
    assert_difference 'Trainer.count', 1 do
      post trainers_path, params: { trainer: { name: "Chris" } }
      assert_response :redirect
    end
    follow_redirect!
    assert_response :success
    assert_match "Chris", response.body
  end

  test "get new trainer form and reject invalid trainer submission" do
    get "/trainers/new"
    assert_response :success
    assert_no_difference 'Trainer.count' do
      post trainers_path, params: { trainer: { name: " " } }
    end
    assert_match "errors", response.body
    assert_select 'div.alert'
    assert_select 'h4.alert-heading'
  end

end
