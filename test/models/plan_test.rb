require "test_helper"

class PlanTest < ActiveSupport::TestCase
  test "should not save plan without name, price_cents and description" do
    plan = Plan.new
    assert_not plan.save
  end

  test "name should be unique" do
    plan1 = Plan.create(name: "Basic Plan", price_cents: 1000, description: "Basic plan description")
    plan2 = Plan.new(name: "Basic Plan", price_cents: 2000, description: "Another basic plan description")
    assert_not plan2.save, "Saved the plan with a duplicate name"
  end

  test "should save valid plan" do
    plan = Plan.new(name: "Premium Plan", price_cents: 2000, description: "Premium plan description")
    assert plan.save, "Failed to save a valid plan"
  end
  
  test "should not save plan with negative price_cents" do
    plan = Plan.new(name: "Invalid Plan", price_cents: -100, description: "Invalid plan description")
    assert_not plan.save, "Saved the plan with a negative price_cents"
  end
end
