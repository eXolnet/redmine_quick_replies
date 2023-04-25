require File.dirname(__FILE__) + '/redmine_quick_replies/hooks/add_replies_link'

require File.dirname(__FILE__) + '/redmine_quick_replies/patches/user_patch'
require File.dirname(__FILE__) + '/redmine_quick_replies/patches/wiki_formatting_patch'

module RedmineQuickReplies
  class << self
    def setup
      Redmine::WikiFormatting::format_names.each do |format|
        unless Redmine::WikiFormatting::helper_for(format).included_modules.include? RedmineQuickReplies::Patches::WikiFormattingPatch
         Redmine::WikiFormatting::helper_for(format).send(:include, RedmineQuickReplies::Patches::WikiFormattingPatch)
        end
      end
    end
  end
end

if Rails.version > '6.0' && Rails.autoloaders.zeitwerk_enabled?
  Rails.application.config.after_initialize do
    RedmineQuickReplies.setup
  end
else
  Rails.configuration.to_prepare do
    RedmineQuickReplies.setup
  end
end
