module EventMachine
  class Instagram
    module Media
      def media(id)
        request :get, "/v1/media/#{id}"
      end

      def media_by_geography(object_id, params = {})
        request :get, "/v1/geographies/#{object_id}/media/recent", :query => default_params.merge(params)
      end

      def media_by_tag(object_id, params = {})
        request :get, "/v1/tags/#{object_id}/media/recent", :query => default_params.merge(params)
      end


      def fetch_geography(object_id)
        @logger.debug "fetching #{object_id} updates..."
        # TODO: figure out if min_id parameter would be appropriate for reading recent tagged media
        request = media_by_geography(object_id)
        request.errback { |error| @logger.debug "fetch error: #{error}";  EventMachine::add_timer(15) { fetch_geography object_id } }
        request.callback { |media| @update_queue.push(*media) }
      end

      def fetch_tag(object_id)
        @logger.debug "fetching #{object_id} updates..."
        # TODO: figure out if max_id or min_id parameter would be appropriate for reading recent tagged media
        request = media_by_tag(object_id)
        request.errback { |error| @logger.debug "fetch error: #{error}";  EventMachine::add_timer(15) { fetch_tag object_id } }
        request.callback { |media| @update_queue.push(*media) }
      end
    end
  end
end