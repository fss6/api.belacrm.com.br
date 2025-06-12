class CreateMailerErrorLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :mailer_error_logs do |t|
      t.string :error_class
      t.text :message
      t.text :backtrace
      t.string :mailer_clas

      t.timestamps
    end
  end
end
