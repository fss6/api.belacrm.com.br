class AccountMailer < ApplicationMailer
    default from: "notifications@example.com"

    def invitation_email
        @account = params[:account]
        @url  = "http://example.com/login"
        mail(to: @account.email, subject: "Welcome to Bela CRM")
    end
end
