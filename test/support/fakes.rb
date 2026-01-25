class FakeRequest
  attr_accessor :path, :body, :content_type, :cookies, :request_method
  attr_reader :request_uri

  def initialize(path:, request_method:, body: nil, content_type: nil, cookies: [])
    @path = path
    @request_uri = Struct.new(:path).new(path)
    @request_method = request_method
    @body = body
    @content_type = content_type
    @cookies = cookies
  end
end

class FakeResponse
  attr_accessor :status, :body, :content_type
  attr_reader :cookies, :redirected_to

  def initialize
    @cookies = []
  end

  def set_redirect(status, url)
    @status = status
    @redirected_to = url
  end
end

class FakeServer
  attr_reader :mounts

  def initialize
    @mounts = {}
  end

  def mount_proc(path, &block)
    @mounts[path] = block
  end
end
