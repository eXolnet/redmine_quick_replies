module RedmineQuickReplies
  module Hooks
    class AddRepliesLink < Redmine::Hook::ViewListener
      def view_my_account_contextual(context)
        user = context[:user]
        link_to(l(:label_quick_replies), replies_path, class: 'icon icon-comment') if user.allowed_to_create_replies?
      end

      def self.default_url_options
        {:script_name => Redmine::Utils.relative_url_root}
      end
    end
  end
end