# HTTP Spec

GET /help

POST /signup
  body: email address
  response: token

POST /login
  header: token
  body: email address

POST /post
  body: post content

GET /list
  body: list of posts

PUT /posts/:id
  body: new post content

DELETE /posts/:id
