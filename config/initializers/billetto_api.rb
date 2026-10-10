Rails.configuration.to_prepare do
  Rails.configuration.billetto_api = BillettoApi::Adapter.new(
    api_key: Rails.application.credentials.dig(:billetto, :api_key).to_s,
    api_secret: Rails.application.credentials.dig(:billetto, :api_secret).to_s
  )
end
