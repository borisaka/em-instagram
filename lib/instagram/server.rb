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
          @updates.push(*JSON.load(@http_post_content))
          response.status = 202
          response.content = 'Accepted'
        else
          response.status = 405
          response.content = 'Method Not Allowed'
        end

        response.send_response
      end

      def process_update
        @updates.pop { |data| subscriber.receive_notification data; EventMachine::next_tick { process_update } }
      end

    end
  end
end