require 'redmine'

REDMINE_QUICK_REPLIES_VERSION_NUMBER = '0.0.1'

Redmine::Plugin.register :redmine_quick_replies do
  name 'Quick Replies'
  author 'eXolnet'
  description 'Save time by creating quick replies that could be reused in any WYSIWYG editors.'
  version REDMINE_QUICK_REPLIES_VERSION_NUMBER
  url 'https://github.com/eXolnet/redmine_quick_replies'
  author_url 'https://www.exolnet.com'

  requires_redmine :version_or_higher => '3.4'
end

require 'redmine_quick_replies'
