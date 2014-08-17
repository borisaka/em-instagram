module EventMachine
  class Instagram
    class Request
      include EventMachine::Deferrable

      def initialize(connection)
        connection.errback { |response| fail response.error }
        connection.callback { |response| process_instagram_response response }
      end

    protected
      def process_instagram_response(response)
        begin
          case response.response_header.status
          when 200
            succeed JSON.parse(response.response)['data']
          else
            fail JSON.parse(response.response)['meta']['error_message']
          end
        rescue JSON::ParserError
          self.logger.error ("Error with response: #{response.response.inspect}")
          fail "Invalid JSON returned"
        end
      end
    end
  end
end