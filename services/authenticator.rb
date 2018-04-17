class Authenticator

  def initialize
    @tokens = {}
    @tokens = { 'a@b.c' => 'foo' }
  end

  def create_user(email)
    # Assumptions:
    # Any email matching `[something] @ [something] . [something]` is valid
    return [ false, "Invalid email address" ] unless email.match(/.+@.+\..+/)
    return [ false, "Email address not available" ] if @tokens[email]

    token = (0...8).map { (97 + rand(26)).chr }.join
    @tokens[email] = token
    [ true, "Remember this: #{token}" ]
  end

  def authenticate(email, token)
    found = @tokens[email]
    found && found == token
  end

end
