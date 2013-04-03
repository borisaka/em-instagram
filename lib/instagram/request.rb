module EventMachine
  class Instagram
    class Request
      include Deferrable

      def initialize(connection)
        connection.errback { |response| fail response.error }
        connection.callback { |response| process_instagram_response response }
      end

    protected
      def process_instagram_response(response)
        case response.response_header.status
        when 200
          succeed JSON.parse(response.response)['data']
        else
          fail JSON.parse(response.response)['meta']['error_message']
        end
      end
    end
  end
end