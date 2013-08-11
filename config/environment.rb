# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
MetadataCensus::Application.initialize!

Ethon.logger.level = Logger::INFO
Tire.configure { logger 'log/elasticsearch.log' }
