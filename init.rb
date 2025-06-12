require 'redmine'

REDMINE_QUICK_REPLIES_VERSION = '1.5.0'

Redmine::Plugin.register :redmine_quick_replies do
  name 'Quick Replies'
  author 'eXolnet'
  description 'Save time by creating quick replies that could be reused in any WYSIWYG editors.'
  version REDMINE_QUICK_REPLIES_VERSION
  url 'https://github.com/eXolnet/redmine_quick_replies'
  author_url 'https://www.exolnet.com'

  requires_redmine :version_or_higher => '5.0'

  permission :create_replies, replies: [:index, :create, :edit, :update, :destroy], require: :loggedin
  permission :manage_public_replies, {}
end

require File.dirname(__FILE__) + '/lib/redmine_quick_replies'
