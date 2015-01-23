module SendgridToolkit
  class Unsubscribes < AbstractSendgridClient
    def add(options = {})
      response = api_post('unsubscribes', 'add', options)
      raise UnsubscribeEmailAlreadyExists if response['message'].include?('already exists')
      response
    end

    def delete(options = {})
      response = api_post('unsubscribes', 'delete', options)
      raise UnsubscribeEmailDoesNotExist if response['message'].include?('does not exist')
      response
    end

    def retrieve(options = {})
      response = api_post('unsubscribes', 'get', options)
      response
    end

    def retrieve_with_timestamps(options = {})
      options.merge! :date => 1
      response = retrieve options
      response.each do |unsubscribe|
        unsubscribe['created'] = Time.parse(unsubscribe['created']+' UTC') if unsubscribe.has_key?('created')
      end
      response
    end

    # https://api.sendgrid.com/v3/asm/groups/:group_id/suppressions
    def add_to_suppression_group(group_id, options = {})
      options[:v3] = true
      response = api_post("asm/groups/#{group_id}/suppressions", nil, options)
      failure = if response['errors']
        response['errors'].any?{|error| error['message'].include?('already exists')}
      else
        false
      end
      raise UnsubscribeEmailAlreadyExists if failure
      response
    end
  end
end