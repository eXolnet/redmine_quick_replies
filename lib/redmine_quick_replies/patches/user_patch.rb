require_dependency 'user'

module RedmineQuickReplies
  module Patches
    module UserPatch
      def self.included(base) # :nodoc:
        base.send(:include, InstanceMethods)
      end

      module InstanceMethods
        def allowed_to_create_replies?
          allowed_to?(:create_replies, nil, global: true)
        end

        def allowed_to_manage_public_replies?
          allowed_to?(:manage_public_replies, nil, global: true)
        end
      end
    end
  end
end

unless User.included_modules.include?(RedmineQuickReplies::Patches::UserPatch)
  User.send(:include, RedmineQuickReplies::Patches::UserPatch)
end
