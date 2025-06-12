require "test_helper"

class AccountTest < ActiveSupport::TestCase
  test "should not save account without name, email, identifier, plan_id" do
    account = Account.new
    assert_not account.save
  end

  test "email should be unique" do
    account = accounts(:one)
    account2 = accounts(:two)
    account2.email = account.email

    assert_not account2.valid?, account2.errors.full_messages.inspect
    assert_not account2.save
  end

  test "email should be valid format" do
    account = accounts(:one)
    account.email = "#{Time.now.to_i}@mail.com"

    assert account.valid?, account.errors.full_messages.inspect
    assert account.save
  end

  test "identifier should be unique" do
    account = accounts(:one)
    plan = plans(:one)

    account2 = Account.new(name: "My Account 2", email: "#{Time.now.to_i}@example.com", identifier: account.identifier, plan_id: plan.id)

    assert_not account2.valid?
    assert_not account2.save
  end

  test "identifier should be valid format" do
    plan = plans(:one)
    account = Account.new(name: "My Account", email: "#{Time.now.to_i}@example.com", identifier: "my_identifier", plan_id: plan.id)

    assert_not account.valid?
    assert_not account.save
  end

  test "should save valid account" do
    plan = plans(:one)
    new_account = accounts(:one).dup

    Account.delete_all

    assert new_account.valid?, new_account.errors.full_messages.inspect
    assert new_account.save
  end

  test "should generate invitation token on create" do
    plan = plans(:one)
    new_account = accounts(:one).dup

    Account.delete_all

    assert new_account.valid?, new_account.errors.full_messages.inspect
    assert new_account.save
    assert_not_nil new_account.invitation_token
  end

  test "should set default status to pending on create" do
    plan = plans(:one)
    new_account = accounts(:one).dup

    Account.delete_all

    assert new_account.valid?, new_account.errors.full_messages.inspect
    assert new_account.save
    assert_equal "pending", new_account.status
    assert new_account.pending?
  end
end
