# HTTP Spec

GET /help

POST /signup
  request body: email address
  response body: token

POST /login
  request header: token
  request body: email address

POST /post
  request body: post content

GET /list
  response body: list of posts

PUT /posts/:id
  request body: new post content

DELETE /posts/:id
