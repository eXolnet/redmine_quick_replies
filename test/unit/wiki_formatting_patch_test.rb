require File.expand_path('../../test_helper', __FILE__)

class WikiFormattingPatchTest < Redmine::HelperTest
  include Redmine::WikiFormatting::CommonMark::Helper

  fixtures :users,
           :replies

  def test_heads_for_wiki_formatter_should_include_visible_replies_only_once
    User.current = User.find(2)

    heads_for_wiki_formatter
    heads_for_wiki_formatter

    header_tags = content_for(:header_tags)

    assert_equal 1, header_tags.scan('redmine_quick_replies = ').size
    assert_equal 1, header_tags.scan(%r{plugin_assets/redmine_quick_replies/replies[^"]*\.js}).size

    replies = JSON.parse(header_tags[/redmine_quick_replies = (\[.*\]);/, 1])
    assert_equal [2, 3], replies.map { |reply| reply['id'] }
  end
end
