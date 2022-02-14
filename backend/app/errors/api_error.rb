class ApiError < StandardError
  MESSAGES = {
    user: {
      not_exist: "User does not exist",
      not_found: "Has no one user founded yet",
      not_create: "Could not create a new user",
      not_update: "Could not update current user",
      not_remove: "Could not remove current user",
      deleted: "The user has been removed from the system",
    },
    token: {
      token_expired: "Token expired or invalid",
    },
    auth: {
      need_confirmation: "You must confirm your account",
      login_in: "Successfully logged in",
      logged_out: "User successfully logged out",
      session_updated: "Session has been updated",
      user_not_exist: "User does not exist",
      unauthorized_access: "Unauthorized access attempted",
      password_incorrect: "Password incorrect",
      missmatching: "Missmatched or invalid token",
      confirmed: "Confirmation success",
      already_confirmed: "User has already confirmed their account",
      not_confirmed: "User has not confirmed their account",
      not_login: "Not logged in",
    }
  }

  attr_reader :type

  def initialize(message = "Error!", type = :unprocessable_entity)
    super(message)
    @type = type
  end
end