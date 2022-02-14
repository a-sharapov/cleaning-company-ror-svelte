class ApiError < StandardError
  MESSAGES = {
    api: {
      wrong_request: "Wrong request, check parameters",
    },
    user: {
      not_exist: "User does not exist",
      not_found: "Has no one user founded yet",
      not_create: "Could not create a new user",
      not_update: "Could not update current user",
      not_remove: "Could not remove current user",
      deleted: "The user has been removed from the system",
    },
    token: {
      not_set: "Tokens invalid or not setted",
      token_expired: "Token expired or invalid",
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
    }
  }

  attr_reader :type

  def initialize(message = "Error!", type = :unprocessable_entity)
    super(message)
    @type = type
  end
end