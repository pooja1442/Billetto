require "net/http"
require "json"

module BillettoApi
  class Adapter
    BASE_URL = "https://billetto.dk/api/v3"

    def initialize(api_key:, api_secret:)
      @api_key = api_key
      @api_secret = api_secret
    end

    def fetch_public_events(limit: 100)
      uri = URI("#{BASE_URL}/public/events")
      uri.query = URI.encode_www_form(limit: limit)

      response = perform_request(uri)
      parse_response(response)
    rescue Net::OpenTimeout, Net::ReadTimeout, Errno::ECONNREFUSED, SocketError => e
      raise BillettoApi::ConnectionError, "Failed to connect to Billetto API: #{e.message}"
    end

    private

    attr_reader :api_key, :api_secret

    def perform_request(uri)
      Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: 10, read_timeout: 30) do |http|
        request = Net::HTTP::Get.new(uri)
        request["Api-Keypair"] = "#{api_key}:#{api_secret}"
        request["Accept"] = "application/json"
        request["Content-Type"] = "application/json"
        http.request(request)
      end
    end

    def parse_response(response)
      case response.code.to_i
      when 200
        body = JSON.parse(response.body, symbolize_names: true)
        validate_response!(body)
        body
      when 401, 403
        raise BillettoApi::ApiError, "Authentication failed (HTTP #{response.code})"
      when 429
        raise BillettoApi::ApiError, "Rate limit exceeded (HTTP 429)"
      when 500..599
        raise BillettoApi::ApiError, "Billetto server error (HTTP #{response.code})"
      else
        raise BillettoApi::ApiError, "Unexpected response from Billetto API (HTTP #{response.code})"
      end
    rescue JSON::ParserError => e
      raise BillettoApi::ApiError, "Invalid JSON response from Billetto API: #{e.message}"
    end

    def validate_response!(body)
      unless body.is_a?(Hash) && body.key?(:data)
        raise BillettoApi::ValidationError, "Unexpected response structure: missing 'data' key"
      end
    end
  end
end
