require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class Bitpagos < OmniAuth::Strategies::OAuth2
      DEFAULT_SCOPE = 'access_profile'

      option :provider_ignores_state, true
      option :client_options, {
        :site               => 'https://www.ripio.com',
        :authorize_url      => '/oauth2/authorize',
        :token_url          => '/oauth2/access_token'
      }

      uid { raw_info['account_number'] }

      info do
        prune!({
          'username'    => raw_info['username'],
          'email'       => raw_info['email'],
          'phone'       => raw_info['phone'],
          'name'        => raw_info['name'],
          'first_name'  => raw_info['first_name'],
          'last_name'   => raw_info['last_name'],
          'image'       => raw_info['picture'],
          'balance'     => raw_info['balance'],
          'urls'        => {
            'profile'   => raw_info['username']
          }
        })
      end

      extra do
        hash = {}
        hash['raw_info'] = raw_info unless skip_info?
        prune! hash
      end

      def raw_info
        @raw_info ||= access_token.params || {}
      end

      def request_phase
        options[:authorize_params] = {
          :client_id      => options['client_id'],
          :response_type  => 'code',
          :scope          => (options['scope'] || DEFAULT_SCOPE)
        }

        super
      end

      private

      def prune!(hash)
        hash.delete_if do |_, value|
          prune!(value) if value.is_a?(Hash)
          value.nil? || (value.respond_to?(:empty?) && value.empty?)
        end
      end
    end
  end
end
