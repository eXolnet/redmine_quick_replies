require File.dirname(__FILE__) + '/redmine_quick_replies/hooks/add_replies_link'

require File.dirname(__FILE__) + '/redmine_quick_replies/patches/user_patch'
require File.dirname(__FILE__) + '/redmine_quick_replies/patches/wiki_formatting_patch'

module RedmineQuickReplies
  class << self
    #
  end
end

Rails.configuration.to_prepare do
  # send Emoji Patches to all wiki formatters available to be able to switch formatter without app restart
  Redmine::WikiFormatting::format_names.each do |format|
    unless Redmine::WikiFormatting::helper_for(format).included_modules.include? RedmineQuickReplies::Patches::WikiFormattingPatch
     Redmine::WikiFormatting::helper_for(format).send(:include, RedmineQuickReplies::Patches::WikiFormattingPatch)
    end
  end
end