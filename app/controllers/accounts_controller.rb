class AccountsController < ApplicationController
  before_action :set_account, only: %i[ show update cancel ]

  # GET /accounts
  def index
    # TODO: Apenas admins podem ver todas as contas
    @accounts = Account.all

    render json: @accounts
  end

  # GET /accounts/1
  def show
    # TODO: Apenas o dono da conta e admins podem ver os detalhes
    render json: @account
  end

  # POST /accounts
  def create
    @account = Account.new(account_params)

    if @account.valid?
      render json: account.errors, status: :unprocessable_entity
    end

    case
    when @account.plan&.free?
      create_with_free_plan(@account)
    when @account.plan&.paid?
      raise "Paid plans (TBD)"
    else
      render json: @account.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /accounts/1
  def update
    # TODO: Apenas o dono da conta pode atualizar os dados
    if @account.update(account_params)
      render json: @account
    else
      render json: @account.errors, status: :unprocessable_entity
    end
  end

  # CANCEL /accounts/1
  def cancel
    @account.status = :cancelled
    @account.save!

    render json: @account
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_account
      @account = Account.find(params.expect(:id))
    end

    def create_with_free_plan(account)
      account.generate_invitation_token
      account.invitation_sent_at = Time.current

      if account.save
        AccountMailer.with(account: account).invitation_email.deliver_later
        render json: account, status: :created, location: account
      else
        render json: account.errors, status: :unprocessable_entity
      end
    end

    # Only allow a list of trusted parameters through.
    def account_params
      params.expect(account: [ :name, :email, :identifier, :plan_id ])
    end
end
