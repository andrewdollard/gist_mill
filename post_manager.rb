class PostManager

  def initialize
    @posts = {}
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
    "Created"
  end

  def list(user)
    posts = @posts[user] || []
    posts
      .sort_by{ |p| p[:time] }
      .reverse
      .map { |p| "#{p[:id]} #{p[:time].to_s} #{p[:text]}" }
      .join("\n")
  end

  def edit(user, id, text)
    post = @posts[user].detect { |p| p[:id] == id }
    return "Post not found" unless post

    @posts[user] = @posts[user]
      .reject { |p| p[:id] == id }
      .unshift(post.merge({
      :text => text,
      :time => Time.now,
    }))

    "Edited"
  end

  def delete(user, id)
    post = @posts[user].detect { |p| p[:id] == id }
    return "Post not found" unless post

    @posts[user] = @posts[user].reject { |p| p[:id] == id }
    "Deleted"
  end

end
