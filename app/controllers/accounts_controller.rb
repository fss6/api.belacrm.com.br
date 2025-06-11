class AccountsController < ApplicationController
  before_action :set_account, only: %i[ show update destroy ]

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
    # TODO: Rota publica, qualquer um pode criar uma conta
    # TODO: O dono deve criar a conta, não um admin
    # TODO: Deve selecionar o plano, e receber o token de convite
    @account = Account.new(account_params)

    if @account.save
      render json: @account, status: :created, location: @account
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

  # DELETE /accounts/1
  def destroy
    # TODO: Deve cancelar a conta, não deletar
    @account.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_account
      @account = Account.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def account_params
      params.expect(account: [ :name, :email, :identifier, :invitation_token, :invitation_sent_at, :plan_expires_at, :plan_id, :status, :active ])
    end
end
