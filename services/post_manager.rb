class PostManager

  def initialize
    @posts = {}
    # @posts = {
    #   'a@b.c' => [
    #     {:id => 'aaa', :text => 'foo', :time => Time.now},
    #     {:id => 'bbb', :text => 'bar', :time => Time.now},
    #     {:id => 'ccc', :text => 'rab', :time => Time.now},
    #   ]
    # }
  end

  def create(user, text)
    @posts[user] ||= []
    id = (0...8).map { (97 + rand(26)).chr }.join
    post = {
      :id => id,
      :text => text,
      :time => Time.now,
    }
    @posts[user].unshift(post)
  end

  def list(user)
    posts = @posts[user] || []
    posts
      .sort_by{ |p| p[:time] }
      .reverse
  end

  def edit(user, id, text)
    post = @posts[user].detect { |p| p[:id] == id }
    return [false, "Post not found"] unless post

    @posts[user] = @posts[user]
      .reject { |p| p[:id] == id }
      .unshift(post.merge({
        :text => text,
        :time => Time.now,
      }))

    [true, "Edited"]
  end

  def delete(user, id)
    @posts[user] = @posts[user].reject { |p| p[:id] == id }
  end

end
