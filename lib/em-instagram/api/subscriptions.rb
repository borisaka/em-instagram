module EventMachine
  class Instagram
    module Subscriptions

      def subscribe_to(options)
        options = options.merge(:aspect => 'media', :callback_url => self.callback_url)
        request_body = default_params.merge(:aspect => 'media', :callback_url => self.callback_url).merge(options)
        request = request(:post, "/v1/subscriptions", :body => request_body)
        request.errback { |error| @logger.debug "subscription error: #{error}"; EventMachine::add_timer(15) { subscribe_to options } }
        request.callback { |response| @logger.debug "next subscription..."; EventMachine::next_tick { subscribe_next } }
      end

      def subscriptions(params = {})
        request :get, "/v1/subscriptions", :query => default_params.merge(params)
      end

      def subscribe(*args)
        @subscription_queue.push(*args)
        subscribe_next
      end

      def unsubscribe(params = {})
        request :delete, "/v1/subscriptions", :query => default_params.merge(params)
      end

      def subscribe_next
        if @subscription_queue.empty?
          @logger.debug "subscribed."
        else
          @subscription_queue.pop { |hash| subscribe_to(hash); subscribe_next }
        end
      end
    end
  end
end