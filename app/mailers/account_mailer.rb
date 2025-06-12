class AccountMailer < ApplicationMailer
    default from: "notifications@example.com"
    
    def invitation_email
        @account = params[:account]
        @url  = "http://example.com/login"

        begin
            mail(to: @account.email, subject: "Welcome to Bela CRM")
        rescue StandardError => e
            log_mailer_error(e)
            raise e # Raise to the Active Job register the error
        end
    end

    # Capture exceptions in mailer actions
    # and log them to the database.
    def log_mailer_error(exception)
        MailerErrorLog.create!(
        error_class: exception.class.to_s,
        message: exception.message,
        backtrace: exception.backtrace.join("\n"),
        mailer_class: self.class.to_s,
        mailer_action: action_name,
        params: mailer_params_to_log
        )
    end

    def mailer_params_to_log
        # Filter sensitive parameters before logging
        method_params = method(action_name).parameters
        params_data = {}
        
        method_params.each do |_, param_name|
        params_data[param_name] = instance_variable_get("@#{param_name}") rescue nil
        end

        # Remove sensitive information like passwords
        params_data.to_json.gsub(/"password":"[^"]+"/, '"password":"[FILTERED]"')
    end
end
