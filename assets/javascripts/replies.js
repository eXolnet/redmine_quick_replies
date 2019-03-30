jsToolBar.prototype.elements.replies = {
    type: 'button',
    title: 'Replies',
    fn: {
        wiki: function() {
            var editor = this,
                dropdown = $('<ul style="position:absolute;"></ul>');

            for (var i = 0; i < redmine_quick_replies.length; i++) {
                var reply = redmine_quick_replies[i],
                    li = $('<li></li>');

                li.data('reply', reply);

                li.text(reply.name).appendTo(dropdown).mousedown(function() {
                    editor.encloseSelection($(this).data('reply').body);
                });
            }

            dropdown.menu().width(200).position({
                my: 'left top',
                at: 'left bottom',
                of: this.toolNodes.replies
            });

            $(document).on('mousedown', function() {
                dropdown.remove();
            });

            $('body').append(dropdown);
        }
    }
};