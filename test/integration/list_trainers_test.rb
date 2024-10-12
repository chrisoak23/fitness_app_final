require "test_helper"

class ListTrainersTest < ActionDispatch::IntegrationTest
  def setup
    @trainer = Trainer.create(name: "Chris")
    @trainer2 = Trainer.create(name: "Eilish")
  end

  test "should show trainers listing" do
    get '/trainers'
    assert_select "a[href=?]", trainer_path(@trainer), text: @trainer.name
    assert_select "a[href=?]", trainer_path(@trainer2), text: @trainer2.name
  end
end
