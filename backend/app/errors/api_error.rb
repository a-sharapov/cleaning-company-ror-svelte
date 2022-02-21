class ApiError < StandardError
  MESSAGES = {
    api: {
      wrong_request: "Wrong request, check parameters",
      activation_send_failure: "Could not send activation code, you must confirm account directly",
      new_password_send_failure: "Could not send new password... Please try again later",
    },
    user: {
      not_exist: "User does not exist",
      not_found: "Has no one user founded yet",
      not_create: "Could not create a new user",
      not_update: "Could not update current user",
      not_remove: "Could not remove current user",
      deleted: "The user has been removed from the system",
      new_password: "Password has been updated, please check your SMS/email",
      invalid_request: "Please check entered data and try again",
    },
    token: {
      not_set: "Tokens are invalid or not setted",
      token_expired: "Token has expired or invalid",
      missmatching: "Missmatched or invalid token",
    },
    auth: {
      update: "Session update completed successfully",
      not_update: "Could not update session token",
      login_in: "Successfully logged in",
      logged_out: "User successfully logged out",
      session_updated: "Session has been updated",
      user_not_exist: "User does not exist",
      unauthorized_access: "Unauthorized access attempted",
      password_incorrect: "Password incorrect",
      confirmed: "Confirmation success",
      need_confirmation: "User must confirm their account",
      already_confirmed: "User has already confirmed their account",
      not_confirmed: "User has not confirmed their account",
      not_login: "Not logged in",
      not_logout: "Not logged out",
      blocked_until: "You account has been locked for 1 hour",
      forbidden: "You are not allowed to access this data",
      service_unavailable: "",
    }
  }

  attr_reader :type
  attr_reader :assets

  def initialize(message = "Error!", type = :unprocessable_entity, assets = nil)
    super(message)
    @type = type
    @assets = assets
  end
end