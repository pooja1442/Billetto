secret_key      = Rails.application.credentials.dig(:clerk, :secret_key)      || ENV["CLERK_SECRET_KEY"]
publishable_key = Rails.application.credentials.dig(:clerk, :publishable_key) || ENV["CLERK_PUBLISHABLE_KEY"]

if secret_key.present? && publishable_key.present?
  Clerk.configure do |c|
    c.secret_key      = secret_key
    c.publishable_key = publishable_key
  end
else
  Rails.logger.warn("Clerk keys are not set — authentication will not work")
end
