class SessionsController < ApplicationController
  def destroy
    if clerk.session
      Clerk::SDK.new.sessions.revoke(session_id: clerk.session["sid"])
    end
    cookies.delete("__session")
    redirect_to ENV.fetch("CLERK_AFTER_SIGN_OUT_URL", "/"), allow_other_host: true
  end
end
