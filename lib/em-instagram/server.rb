require 'evma_httpserver/response'
require 'json'

module EventMachine
  class Instagram
    module Server
      include EventMachine::HttpServer

      attr_accessor :subscriber

      def initialize
        @updates = EventMachine::Queue.new
        process_update
        super
      end

      def process_http_request
        response = EventMachine::DelegatedHttpResponse.new(self)
        case @http_request_method
        when 'GET'
          params = CGI::parse(@http_query_string)
          response.status = 200
          response.content = params['hub.challenge']
        when 'POST'
          if valid_instagram_response?
            begin
              @updates.push(*JSON.load(@http_post_content))
              response.status = 202
              response.content = 'Accepted'
            rescue JSON::ParserError
              response.status = 400
              response.content = "Invalid JSON"
            end
          else
            response.status = 401
            response.content = "Invalid Request"
          end
        else
          response.status = 405
          response.content = 'Method Not Allowed'
        end

        response.send_response
      end

      def process_update
        @updates.pop { |data| self.subscriber.receive_notification data; EventMachine::next_tick { process_update } }
      end

      def valid_instagram_response?
        return false if @http_headers.to_s.size == 0
        sig_arr = @http_headers.split("\x00").select do |header|
          header.include?("X-Hub-Signature".downcase)
        end
        sig = if sig_arr.size > 0
          sig_arr.first.split(":").last.strip
        else
          nil
        end
        digest = OpenSSL::Digest::Digest.new('sha1')
        verify_signature = OpenSSL::HMAC.hexdigest(digest, self.subscriber.client_secret, @http_post_content)
        sig && sig == verify_signature
      end

    end
  end
end