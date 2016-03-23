module Notime
  class Errors
    class NoKeySet < StandardError; end
    class AuthenticationFailed < StandardError; end
    class ApiError < StandardError; end
  end
end
