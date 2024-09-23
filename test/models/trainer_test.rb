require 'test_helper'

class CategoryTest < ActiveSupport::TestCase

  def setup
    @trainer = Trainer.new(name: "Chris")
  end

  test "trainer should be valid" do
    assert @trainer.valid?
  end

  test "name should be present" do
    @trainer.name = " "
    assert_not @trainer.valid?
  end

  test "name should be unique" do
    @trainer.save
    @trainer2 = Trainer.new(name: "Chris")
    assert_not @trainer2.valid?
  end

  test "name should not be too long" do
    @trainer.name = "a" *51
    assert_not @trainer.valid?
  end

  test "name should not be too short" do
    @trainer.name = ""
    assert_not @trainer.valid?
  end

end