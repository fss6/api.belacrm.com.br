require "test_helper"

class AccountsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @account = accounts(:one)
  end

  test "should get index" do
    get accounts_url, as: :json
    assert_response :success
  end

  test "should create account" do
    assert_difference("Account.count") do
      post accounts_url, params: { account: { active: @account.active, email: @account.email, identifier: @account.identifier, invitation_sent_at: @account.invitation_sent_at, invitation_token: @account.invitation_token, name: @account.name, plan_expires_at: @account.plan_expires_at, plan_id: @account.plan_id, status: @account.status } }, as: :json
    end

    assert_response :created
  end

  test "should show account" do
    get account_url(@account), as: :json
    assert_response :success
  end

  test "should update account" do
    patch account_url(@account), params: { account: { active: @account.active, email: @account.email, identifier: @account.identifier, invitation_sent_at: @account.invitation_sent_at, invitation_token: @account.invitation_token, name: @account.name, plan_expires_at: @account.plan_expires_at, plan_id: @account.plan_id, status: @account.status } }, as: :json
    assert_response :success
  end

  test "should destroy account" do
    assert_difference("Account.count", -1) do
      delete account_url(@account), as: :json
    end

    assert_response :no_content
  end
end
