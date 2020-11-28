require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ToyApp
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
    require 'opentelemetry/sdk'
    require 'opentelemetry/exporter/jaeger'

    OpenTelemetry::SDK.configure do |c|
      c.use 'OpenTelemetry::Instrumentation::Rails'
      c.use 'OpenTelemetry::Instrumentation::Mysql2'
      c.add_span_processor(
        OpenTelemetry::SDK::Trace::Export::BatchSpanProcessor.new(
          exporter: OpenTelemetry::Exporter::Jaeger::AgentExporter.new(host: 'host.docker.internal', port: 6831)
        )
      )
      c.service_name = 'toy-app'
      c.service_version = '0.1.0'
    end
  end
end
