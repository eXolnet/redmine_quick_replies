module RedmineQuickReplies
  module Patches
    module WikiFormattingPatch
      extend ActiveSupport::Concern

      included do
        prepend InstanceOverwriteMethods
      end

      module InstanceOverwriteMethods
        def heads_for_wiki_formatter
          super

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
