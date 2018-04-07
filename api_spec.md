# Project specs

* Reverse-chronological list of text blobs
* New, Edit
  - Save, Cancel


## Command Interface

* `help`
    - shows a list of commands

* `signup <email-address>`
    - if there is not a current session user:
      * If the email is invalid:
          - display error message

      * if a user record with the given email does not already exist:
          - create a user with the given address and generate a token
          - email the token to the email address

      * if a user record with the given email already exists:
          - display error message

    - if there is a current session user:
        * display an error message

* `login <email-address> <token>`
    * if a user record with the given email already exists:
        - if the token is correct:
           * set the provided user as the session user
        - if the token is incorrect:
           * display an 'invalid email or token' error

    * if a user record with the given email does not already exist:
        - display an 'invalid email or token' error

* `list`
    - if a session user is set:
      * show a list of the session user's posts
      * posts are sorted in reverse-chronological order
    - if not, display sign-in message

* `post "some post text"`
    - if a session user is set:
        * create a post with the provided text
        * generate ID for post
        * set timestamp of post to current time
        * set post user_email address to session user email address
        * return the ID of the created post

    - if not, display sign-in message

* `edit <post-id> "some new post text"`
    - if a session user is set:
        * if the post exists:
            - if the post belongs to the user:
                * update the text of the post with the provided ID
            - if the post does not belong to the user:
                * display error message
        * if the post does not exist:
            - display error message

    - if not, display sign-in message

* `del <post-id>`
    - if a session user is set:
        * if the post exists:
            - if the post belongs to the user:
                * delete the post
            - if the post does not belong to the user:
                * display error message
        * if the post does not exist:
            - display error message

    - if not, display sign-in message

## Models

* User
  - email address
    * does not contain spaces
    * is unique
  - auth token (password)

* Post
  - ID
    * is unique per user
  - text
  - timestamp
  - user email address


