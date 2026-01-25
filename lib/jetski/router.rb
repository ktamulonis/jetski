class Jetski
  class Router
    include Parser

    attr_reader :server, :routes, :crud_routes

    def initialize(server)
      @server = server
      @crud_routes = []
    end

    def call
      browser_support
      fetch_routes
      host_routes
      host_crud_routes
      host_assets
      host_stream
    end

    # ------------------------------------------------------------
    # ROUTES
    # ------------------------------------------------------------
    def host_routes
      crud_actions = %w[new create show index edit update destroy]

      routes.each do |route|
        if crud_actions.include?(route[:action_name]) && route[:url] != "/"
          @crud_routes << route
          next
        end

        Host::Controller.new(server, **route).call
      end
    end

    def host_crud_routes
      crud_routes.group_by { |r| r[:controller_path] }.each do |_path, routes|
        Host::Crud.new(server, routes, **routes.first).call
      end
    end

    # ------------------------------------------------------------
    # ASSETS
    # ------------------------------------------------------------
    def host_assets
      host_css
      host_images
      host_javascript
      host_javascript_helpers
    end

    def host_css
      Dir[File.join(Jetski.app_root, "app/assets/stylesheets/**/*.css")].each do |file|
        name = file.split("stylesheets/").last
        server.mount_proc("/#{name}") { |_req, res| res.body = File.read(file) }
      end
    end

    def host_images
      Dir[File.join(Jetski.app_root, "app/assets/images/*")].each do |file|
        name = File.basename(file)
        server.mount_proc("/#{name}") { |_req, res| res.body = File.read(file) }
      end
    end

    def host_javascript
      Dir[File.join(Jetski.app_root, "app/assets/javascript/**/*.js")].each do |file|
        name = file.split("javascript/").last
        server.mount_proc("/#{name}") { |_req, res| res.body = File.read(file) }
      end
    end

    def host_javascript_helpers
      server.mount_proc "/reactive-form.js" do |_req, res|
        res.body = File.read(File.join(__dir__, "frontend/javascript_helpers.js"))
      end
    end

    # ------------------------------------------------------------
    # 🔥 SERVER-SENT EVENTS (WEBrick-compatible)
    # ------------------------------------------------------------
    def host_stream
      server.mount_proc "/stream" do |_req, res|
        res.status = 200
        res["Content-Type"]  = "text/event-stream"
        res["Cache-Control"] = "no-cache"
        res["Connection"]    = "keep-alive"

        # ❌ DO NOT enable chunked for WEBrick
        # res.chunked = true

        res.body = proc do |out|
          # Force header flush
          connected = true

          begin
            out << ": connected\n\n"
          rescue IOError, Errno::EPIPE
            connected = false
          end

          if connected
            writer = proc do |data|
              # 🔒 WEBrick REQUIRES String
              out << data.to_s
            end

            Jetski::Stream.subscribe(&writer)

            begin
              loop do
                break if Jetski::Stream.wait_for_shutdown(15)

                begin
                  out << ": ping\n\n"
                rescue IOError, Errno::EPIPE
                  break
                end
              end
            ensure
              Jetski::Stream.unsubscribe(writer)
            end
          end
        end
      end
    end

    # ------------------------------------------------------------
    def browser_support
      server.mount_proc "/favicon.ico" do |_req, res|
        res.status = 204
      end
    end

    private

    def fetch_routes
      @routes ||= compile_routes
    end
  end
end
