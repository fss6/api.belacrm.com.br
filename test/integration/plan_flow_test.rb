require "test_helper"

class PlanFlowTest < ActionDispatch::IntegrationTest
  test "can see the plan list" do
    get "/plans"
    assert_response :success
  end

  test "can create a pan" do
    name = "Plan #{Time.now}"
    params = { plan: { name: name, description: "My description", price_cents: 100 } }
    post "/plans", params: params

    assert_equal 201, response.status

    # Assert the response body
    response_json = JSON.parse(response.body)
    assert_equal name, response_json["name"]
    assert_equal "My description", response_json["description"]
    assert_equal 100, response_json["price_cents"]
    assert_equal "monthly", response_json["interval"]
    assert_equal false, response_json["whatsapp_notifications"]
    assert_equal false, response_json["email_notifications"]
    assert_nil response_json["client_limit"]
    assert_nil response_json["professional_limit"]
    assert_nil response_json["appointments_limit"]
  end

  test "can see a plan" do
    # Create a plan first
    # This is necessary to ensure that the plan exists before we try to retrieve it
    # Otherwise, the test will fail because it won't find the plan
    name = "Plan #{Time.now}"
    params = { plan: { name: name, description: "My description", price_cents: 100 } }
    post "/plans", params: params
    assert_equal 201, response.status

    # Now retrieve the plan
    # We can use the response from the previous post request to get the plan ID
    # This assumes that the response body contains the plan ID in a predictable format
    # For example, if the response body is JSON and contains an "id" field
    plan_id = JSON.parse(response.body)["id"]
    get "/plans/#{plan_id}"
    assert_response :success
    response_json = JSON.parse(response.body)
    assert_equal name, response_json["name"]
    assert_equal "My description", response_json["description"]
    assert_equal 100, response_json["price_cents"]
    assert_equal "monthly", response_json["interval"]
    assert_equal false, response_json["whatsapp_notifications"]
    assert_equal false, response_json["email_notifications"]
    assert_nil response_json["client_limit"]
    assert_nil response_json["professional_limit"]
    assert_nil response_json["appointments_limit"]
  end

  test "can update a plan" do
    # Create a plan first
    name = "Plan #{Time.now}"
    params = { plan: { name: name, description: "My description", price_cents: 100 } }
    post "/plans", params: params
    assert_equal 201, response.status
    # Retrieve the plan ID from the response
    plan_id = JSON.parse(response.body)["id"]
    # Now update the plan
    updated_params = { plan: { name: "Updated Plan", description: "Updated description", price_cents: 200 } }
    put "/plans/#{plan_id}", params: updated_params
    assert_response :success
    # Assert the response body
    response_json = JSON.parse(response.body)
    assert_equal "Updated Plan", response_json["name"]
    assert_equal "Updated description", response_json["description"]
    assert_equal 200, response_json["price_cents"]
    assert_equal "monthly", response_json["interval"]
    assert_equal false, response_json["whatsapp_notifications"]
    assert_equal false, response_json["email_notifications"]
    assert_nil response_json["client_limit"]
    assert_nil response_json["professional_limit"]
    assert_nil response_json["appointments_limit"]
  end

  test "can delete a plan" do
    # Create a plan first
    name = "Plan #{Time.now}"
    params = { plan: { name: name, description: "My description", price_cents: 100 } }
    post "/plans", params: params
    assert_equal 201, response.status
    # Retrieve the plan ID from the response
    plan_id = JSON.parse(response.body)["id"]
    # Now delete the plan
    delete "/plans/#{plan_id}"
    assert_response :no_content
    # Assert that the plan was deleted
    # We can do this by trying to retrieve the plan again and expecting a 404 response
    get "/plans/#{plan_id}"
    assert_response :not_found
    # Optionally, you can also check that the plan no longer exists in the database
    # plan = Plan.find_by(id: plan_id)
    # assert_nil plan, "Plan was not deleted from the database"
  end
end
