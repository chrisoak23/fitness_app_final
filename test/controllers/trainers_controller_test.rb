require "test_helper"

class TrainersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @trainer = Trainer.create(name: "Chris")
    @admin_user = User.create(username: "johndoe", email: "johndoe@example.com",
                              password: "password", admin: true)
  end

  test "should get index" do
    get trainers_url
    assert_response :success
  end

  test "should get new" do
    sign_in_as(@admin_user)
    get new_trainer_url
    assert_response :success
  end

  test "should create trainer" do
    sign_in_as(@admin_user)
    assert_difference("Trainer.count", 1) do
      post trainers_url, params: { trainer: { name: "Eilish" } }
    end

    assert_redirected_to trainer_url(Trainer.last)
  end

  test "should not create trainer if not admin" do
    assert_no_difference("Trainer.count") do
      post trainers_url, params: { trainer: { name: "Eilish" } }
    end

    assert_redirected_to trainers_url
  end

  test "should show trainer" do
    get trainer_url(@trainer)
    assert_response :success
  end

  # test "should get edit" do
  #   get edit_trainer_url(@trainer)
  #   assert_response :success
  # end

  # test "should update trainer" do
  #   patch trainer_url(@trainer), params: { trainer: {  } }
  #   assert_redirected_to trainer_url(@trainer)
  # end

  # test "should destroy trainer" do
  #   assert_difference("Trainer.count", -1) do
  #     delete trainer_url(@trainer)
  #   end

  #   assert_redirected_to trainers_url
  # end
end
