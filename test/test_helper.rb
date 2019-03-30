$VERBOSE = nil # for hide ruby warnings

# Load the Redmine helper
require File.expand_path(File.dirname(__FILE__) + '/../../../test/test_helper')

# Enable project fixtures
ActiveRecord::FixtureSet.create_fixtures(File.dirname(__FILE__) + '/fixtures/', [:replies])
