require "test_helper"

class PlansControllerTest < ActionDispatch::IntegrationTest
  setup do
    @plan = plans(:one)
  end

  test "should get index" do
    abort Plan.count.inspect
    get plans_url, as: :json
    assert_response :success
  end

  test "should create plan" do
    assert_difference("Plan.count") do
      plan_name = "Test Plan #{Time.now.to_i}" # Ensure unique name for each test run
      post plans_url, params: { plan: { client_limit: @plan.client_limit, description: @plan.description, interval: @plan.interval, name: plan_name, price_cents: @plan.price_cents, professional_limit: @plan.professional_limit, whatsapp_notifications: @plan.whatsapp_notifications } }, as: :json
    end

    assert_response :created
  end

  test "should show plan" do
    get plan_url(@plan), as: :json
    assert_response :success
  end

  test "should update plan" do
     patch plan_url(@plan), params: { plan: { client_limit: @plan.client_limit, description: @plan.description, interval: @plan.interval, name: @plan.name, price_cents: @plan.price_cents, professional_limit: @plan.professional_limit, whatsapp_notifications: @plan.whatsapp_notifications } }, as: :json
     assert_response :success
  end

  test "should destroy plan" do
    assert_difference("Plan.count", -1) do
      delete plan_url(@plan), as: :json
    end

    assert_response :no_content
  end
end
