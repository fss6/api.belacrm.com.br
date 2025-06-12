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
    params = { email: "#{Time.now.to_i}@example.com", identifier: 76556868310, name: @account.name, plan_id: @account.plan_id }
    account = Account.new(params)

    assert_difference("Account.count") do
      post accounts_url, params: { account: params }, as: :json
    end

    assert_response :created
  end

  test "should show account" do
    get account_url(@account), as: :json
    assert_response :success
  end

  test "should update account" do
    patch account_url(@account), params: { account: { email: @account.email, identifier: @account.identifier, name: @account.name, plan_id: @account.plan_id } }, as: :json
    assert_response :success
  end

  test "should cancel account" do
    assert @account.valid?, @account.errors.full_messages.inspect

    patch cancel_accounts_path(@account), as: :json

    assert_response :success
  end
end
