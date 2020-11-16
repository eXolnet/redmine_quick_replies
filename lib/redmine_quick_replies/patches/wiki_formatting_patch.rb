module RedmineQuickReplies
  module Patches
    module WikiFormattingPatch
      def self.included(base) # :nodoc:
        base.send(:include, InstanceMethods)

        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in development

          alias_method :heads_for_wiki_formatter_without_redmine_quick_replies, :heads_for_wiki_formatter
          alias_method :heads_for_wiki_formatter, :heads_for_wiki_formatter_with_redmine_quick_replies
        end
      end

      module InstanceMethods
        def heads_for_wiki_formatter_with_redmine_quick_replies
            heads_for_wiki_formatter_without_redmine_quick_replies

            return if @heads_for_wiki_redmine_quick_replies_included

            content_for :header_tags do
                replies = Reply.visible.sorted.to_json

                o = javascript_tag("redmine_quick_replies = " + replies + ";")
                o << javascript_include_tag('replies', :plugin => 'redmine_quick_replies')
                o << stylesheet_link_tag('replies', :plugin => 'redmine_quick_replies')
                o.html_safe
            end

            @heads_for_wiki_redmine_quick_replies_included = true
          end
      end
    end
  end
end
