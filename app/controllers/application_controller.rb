class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  include Clerk::Authenticatable

  private

  def require_clerk_session!
    unless clerk.session
      sign_in_url = "#{clerk.sign_in_url}?redirect_url=#{CGI.escape(request.url)}"
      redirect_to sign_in_url, allow_other_host: true
    end
  end
end
