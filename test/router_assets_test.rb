require_relative "test_helper"
require "tmpdir"
require "fileutils"

class RouterAssetsTest < Minitest::Test
  def test_host_assets_mounts_files
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        FileUtils.mkdir_p("app/assets/stylesheets")
        FileUtils.mkdir_p("app/assets/javascript")
        FileUtils.mkdir_p("app/assets/images")
        File.write("app/assets/stylesheets/application.css", "body { }")
        File.write("app/assets/javascript/application.js", "console.log('hi');")
        File.write("app/assets/images/logo.png", "png")

        server = FakeServer.new
        router = Jetski::Router.new(server)
        router.host_assets

        assert server.mounts.key?("/application.css")
        assert server.mounts.key?("/application.js")
        assert server.mounts.key?("/logo.png")
        assert server.mounts.key?("/reactive-form.js")
      end
    end
  end
end
