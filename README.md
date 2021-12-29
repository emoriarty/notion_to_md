# notion_to_md
Notion Markdown Exporter in Ruby.

## Installation
Use gem to install.
```bash
$ gem install 'notion_to_md'
```

Or add it to the `Gemfile`.
```ruby
# Gemfile
gem 'notion_to_md'
```

## Usage
Before using the gem create an integration and generate a secret token. Check [notion getting started guide](https://developers.notion.com/docs/getting-started) to learn more.

Pass the page id and secret token to the constructor and execute the `convert` method.

```ruby
require 'notion_to_md'

notion_converter = NotionToMd::Converter.new(page_id: 'b91d5...', token: 'secret_...')
md = notion_converter.convert
```

If the secret token is provided as an environment variable —`NOTION_TOKEN`—, there's no need to pass it as an argument to the constructor.

```bash
$ export NOTION_TOKEN=<secret_...>
```

```ruby
require 'notion_to_md'

notion_converter = NotionToMd::Converter.new(page_id: 'b91d5...')
md = notion_converter.convert
```

And that's all. The `md` is a string variable containing the notion page formatted in markdown.