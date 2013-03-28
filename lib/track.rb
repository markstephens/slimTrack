module FT
  module Analytics
    class Track

      def self.page(server)
        new(:page, server)
      end
      
      def initialize(type, server)
        request_info(server.logger, server.request)
      end

      
      
      
      private

      def request_info(logger, request)
        logger.info "request.accept: #{request.accept}"              # ['text/html', '*/*']
        logger.info "request.body: #{request.body}"                # logger.info request body sent by the client (see below)
        logger.info "request.scheme: #{request.scheme}"              # "http"
        logger.info "request.script_name: #{request.script_name}"         # "/example"
        logger.info "request.path_info: #{request.path_info}"           # "/foo"
        logger.info "request.port: #{request.port}"                # 80
        logger.info "request.request_method: #{request.request_method}"      # "GET"
        logger.info "request.query_string: #{request.query_string}"        # ""
        logger.info "request.content_length: #{request.content_length}"      # length of logger.info request.body
        logger.info "request.media_type: #{request.media_type}"          # media type of logger.info request.body
        logger.info "request.host: #{request.host}"                # "example.com"
        logger.info "request.get?: #{request.get?}"                # true (similar methods for other verbs)
        logger.info "request.form_data?: #{request.form_data?}"          # false
        logger.info "request[\"d\"]: #{request["d"]}"       # value of some_param parameter. [] is a shortcut to the params hash.
        logger.info "request.referrer: #{request.referrer}"            # the referrer of the client or '/'
        logger.info "request.user_agent: #{request.user_agent}"          # user agent (used by :agent condition)
        logger.info "request.cookies: #{request.cookies}"             # hash of browser cookies
        logger.info "request.xhr?: #{request.xhr?}"                # is this an ajax logger.info request?
        logger.info "request.url: #{request.url}"                 # "http://example.com/example/foo"
        logger.info "request.path: #{request.path}"                # "/example/foo"
        logger.info "request.ip: #{request.ip}"                  # client IP address
        logger.info "request.secure?: #{request.secure?}"             # false (would be true over ssl)
        logger.info "request.forwarded?: #{request.forwarded?}"          # true (if running behind a reverse proxy)
        logger.info "request.env: #{request.env}"                 # raw env hash handed in by Rack
      end
    end
  end
end

