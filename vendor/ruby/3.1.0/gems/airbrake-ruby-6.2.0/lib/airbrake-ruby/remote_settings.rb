module Airbrake
  # RemoteSettings polls the remote config of the passed project at fixed
  # intervals. The fetched config is yielded as a callback parameter so that the
  # invoker can define read config values. Supports proxies.
  #
  # @example Disable/enable error notifications based on the remote value
  #   RemoteSettings.poll do |data|
  #     config.error_notifications = data.error_notifications?
  #   end
  #
  # @since v5.0.0
  # @api private
  class RemoteSettings
    include Airbrake::Loggable

    # @return [Hash{Symbol=>String}] metadata to be attached to every GET
    #   request
    QUERY_PARAMS = URI.encode_www_form(
      notifier_name: Airbrake::NOTIFIER_INFO[:name],
      notifier_version: Airbrake::NOTIFIER_INFO[:version],
      os: RUBY_PLATFORM,
      language: "#{RUBY_ENGINE}/#{RUBY_VERSION}".freeze,
    ).freeze

    # @return [String]
    HTTP_OK = '200'.freeze

    # Polls remote config of the given project.
    #
    # @param [Integer] project_id
    # @param [String] host
    # @yield [data]
    # @yieldparam data [Airbrake::RemoteSettings::SettingsData]
    # @return [Airbrake::RemoteSettings]
    def self.poll(project_id, host, &block)
      new(project_id, host, &block).poll
    end

    # @param [Integer] project_id
    # @yield [data]
    # @yieldparam data [Airbrake::RemoteSettings::SettingsData]
    def initialize(project_id, host, &block)
      @data = SettingsData.new(project_id, {})
      @host = host
      @block = block
      @config = Airbrake::Config.instance
      @poll = nil
    end

    # Polls remote config of the given project in background.
    #
    # @return [self]
    def poll
      @poll ||= Thread.new do
        @block.call(@data)

        loop do
          @block.call(@data.merge!(fetch_config))
          sleep(@data.interval)
        end
      end

      self
    end

    # Stops the background poller thread.
    #
    # @return [void]
    def stop_polling
      @poll.kill if @poll
    end

    private

    def fetch_config
      uri = build_config_uri
      https = build_https(uri)
      req = Net::HTTP::Get.new(uri.request_uri)
      response = nil

      begin
        response = https.request(req)
      rescue StandardError => ex
        reason = "#{LOG_LABEL} HTTP error: #{ex}"
        logger.error(reason)
        return {}
      end

      unless response.code == HTTP_OK
        logger.error(response.body)
        return {}
      end

      json = nil
      begin
        json = JSON.parse(response.body)
      rescue JSON::ParserError => ex
        logger.error(ex)
        return {}
      end

      json
    end

    def build_config_uri
      uri = URI(@data.config_route(@host))
      uri.query = QUERY_PARAMS
      uri
    end

    def build_https(uri)
      Net::HTTP.new(uri.host, uri.port, *proxy_params).tap do |https|
        https.use_ssl = uri.is_a?(URI::HTTPS)
        if @config.timeout
          https.open_timeout = @config.timeout
          https.read_timeout = @config.timeout
        end
      end
    end

    def proxy_params
      return unless @config.proxy.key?(:host)

      [@config.proxy[:host], @config.proxy[:port], @config.proxy[:user],
       @config.proxy[:password]]
    end
  end
end
