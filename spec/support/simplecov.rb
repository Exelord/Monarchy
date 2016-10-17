require 'simplecov'

SimpleCov.start('rails') do
  adapters.delete(:root_filter)

  filters.clear
  add_filter "dummy/"
  add_filter "spec/"
  add_filter "lib/generators/"
  add_filter "lib/monarchy/version.rb"
  add_filter do |src|
    !(src.filename =~ /^#{SimpleCov.root}/) unless src.filename =~ /\/monarchy\//
  end

  groups.clear
  add_group "Models", "app/models"
  add_group "Libs", "lib/"
end if ENV['COVERAGE']
