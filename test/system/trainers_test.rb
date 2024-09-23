require "application_system_test_case"

class TrainersTest < ApplicationSystemTestCase
  setup do
    @trainer = trainers(:one)
  end

  test "visiting the index" do
    visit trainers_url
    assert_selector "h1", text: "Trainers"
  end

  test "should create trainer" do
    visit trainers_url
    click_on "New trainer"

    click_on "Create Trainer"

    assert_text "Trainer was successfully created"
    click_on "Back"
  end

  test "should update Trainer" do
    visit trainer_url(@trainer)
    click_on "Edit this trainer", match: :first

    click_on "Update Trainer"

    assert_text "Trainer was successfully updated"
    click_on "Back"
  end

  test "should destroy Trainer" do
    visit trainer_url(@trainer)
    click_on "Destroy this trainer", match: :first

    assert_text "Trainer was successfully destroyed"
  end
end
