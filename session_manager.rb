class SessionManager

  def initialize
    @tokens = {}
    @curren_user
    # @tokens = { 'a@b.c' => 'foo' }
    # @current_user = 'a@b.c'
  end

  def create_user(email)
    # Assumptions:
    # Any email matching `[something] @ [something] . [something]` is valid
    return "Invalid email address" unless email.match(/.+@.+\..+/)
    return "Email address not available" if @tokens[email]

    token = (0...8).map { (97 + rand(26)).chr }.join
    @tokens[email] = token
    "Remember this: #{token}"
  end

  def create_session(email, token)
    found = @tokens[email]
    return "Invalid email address or token" unless found && found == token

    @current_user = email
    "Ok"
  end

  def current_user
    @current_user
  end

end
