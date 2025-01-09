# Redmine Quick Replies

[![Latest Release](https://img.shields.io/github/release/eXolnet/redmine_quick_replies.svg?style=flat-square)](https://github.com/eXolnet/redmine_quick_replies/releases)
![Redmine Compatibility](https://img.shields.io/static/v1?label=redmine&message=4.2.x-5.1.x&color=blue&style=flat-square)
[![Software License](https://img.shields.io/badge/license-MIT-8469ad.svg?style=flat-square)](LICENSE)
[![Build Status](https://img.shields.io/github/actions/workflow/status/eXolnet/redmine_quick_replies/tests.yml?label=tests&style=flat-square)](https://github.com/eXolnet/redmine_quick_replies/actions?query=workflow%3Atests)
[![Maintainability](https://api.codeclimate.com/v1/badges/3789abac23b73a9bf71b/maintainability)](https://codeclimate.com/github/eXolnet/redmine_quick_replies/maintainability)

Save time by creating quick replies that could be reused in any WYSIWYG editors.

## Compatibility

This plugin version is compatible only with Redmine 4.2 and later.

## Installation

1. Download the .ZIP archive, extract files and copy the plugin directory to `#{REDMINE_ROOT}/plugins/redmine_quick_replies`.

2. Make a backup of your database, then run the following command to update it:

    ```bash
    bundle exec rake redmine:plugins:migrate NAME=redmine_quick_replies RAILS_ENV=production
    ```

3. Restart Redmine.

### Uninstall

1. Make a backup of your database, then rollback the migrations:

    ```bash
    bundle exec rake redmine:plugins:migrate NAME=redmine_quick_replies VERSION=0 RAILS_ENV=production
    ```

2. Remove the plugin's folder from `#{REDMINE_ROOT}/plugins`.

3. Restart Redmine.

## Usage

### Using quick replies

Quick replies could be used on any WYSIWYG editor available on Redmine:

1. Click on the "Quick Replies" button;
2. Select the quick reply that you want to append by its name.

![Accessing the quick replies menu](https://github.com/eXolnet/redmine_quick_replies/blob/master/doc/images/access-quick-replies.png?raw=true)

### Managing quick replies

Access your quick replies through your account:

1. Click on the "My account" on Redmine's top menu;
2. Click on the "Quick replies";
3. Create, edit or delete your quick replies though this page.

![Page to manage quick replies](https://github.com/eXolnet/redmine_quick_replies/blob/master/doc/images/managing-quick-replies.png?raw=true)

## Testing

Run tests using the following command:

```bash
bundle exec rake redmine:plugins:test NAME=redmine_quick_replies RAILS_ENV=test
```

## Contributing

Please see [CONTRIBUTING](CONTRIBUTING.md) and [CODE OF CONDUCT](CODE_OF_CONDUCT.md) for details.

## Security

If you discover any security related issues, please email security@exolnet.com instead of using the issue tracker.

## Credits

- [Alexandre D'Eschambeault](https://github.com/xel1045)
- [All Contributors](../../contributors)

## License

Copyright © [eXolnet](https://www.exolnet.com). All rights reserved.

This code is licensed under the [MIT license](http://choosealicense.com/licenses/mit/).
Please see the [license file](LICENSE) for more information.
