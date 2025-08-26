# notion_to_md
A Ruby library to export Notion pages to Markdown.

The generated Markdown is fully compliant with the [GitHub Flavored Markdown specification](https://github.github.com/gfm/).

## Installation

Install via RubyGems:

```bash
gem install notion_to_md
```

Or add it to your `Gemfile`:

```ruby
# Gemfile
gem 'notion_to_md'
```

## Usage

Before using the gem, create a Notion integration and generate a secret token. See the [Notion Getting Started Guide](https://developers.notion.com/docs/getting-started) for details.

Pass the page ID and secret token to the constructor and call `convert`:

```ruby
require 'notion_to_md'

notion_converter = NotionToMd::Converter.new(page_id: 'b91d5...', token: 'secret_...')
md = notion_converter.convert
```

Since v2.3, you can also use the convenient shorthand:

```ruby
md = NotionToMd.convert(page_id: 'b91d5...', token: 'secret_...')
```

### Using environment variables

If your secret token is stored in the `NOTION_TOKEN` environment variable, you don’t need to pass it explicitly:

```bash
export NOTION_TOKEN=<secret_...>
```

```ruby
notion_converter = NotionToMd::Converter.new(page_id: 'b91d5...')
md = notion_converter.convert
# or
md = NotionToMd.convert(page_id: 'b91d5...')
```

The result (`md`) is a string containing the page content formatted in Markdown.

### Callable interface

As of v2.5.0, the `call` method is available as an alias for `convert`:

```ruby
md = NotionToMd.call(page_id: 'b91d5...')
```

The `call` method also accepts a block:

```ruby
NotionToMd.call(page_id: 'b91d5...') { puts _1 }
```

## Supported blocks

Everything in a Notion page is a [block object](https://developers.notion.com/reference/block#block-object-keys). Not all block types map directly to Markdown, but the following are supported:

- `paragraph`
- `heading_1`
- `heading_2`
- `heading_3`
- `bulleted_list_item`
- `numbered_list_item` (added in v2.3; previously rendered as `bulleted_list_item`)
- `to_do`
- `image`
- `bookmark`
- `callout`
- `quote`
- `divider`
- `table`
- `embed`
- `code`
- `link_preview`
- `file`
- `pdf`
- `video`
- `equation`

### Nested blocks

Since v2, nested blocks are supported. The following block types may contain children:

- `paragraph`
- `bulleted_list_item`
- `numbered_list_item`
- `to_do`

## Front matter

Since v0.2.0, `notion_to_md` supports YAML front matter in exported Markdown.

By default, front matter is not included. To enable it, pass the `frontmatter: true` option:

```ruby
NotionToMd::Converter.new(page_id: 'b91d5...').convert(frontmatter: true)
# or (since v2.3)
NotionToMd.convert(page_id: 'b91d5...', frontmatter: true)
```

### Default properties

By default, the following [Notion page properties](https://developers.notion.com/reference/page#all-pages) are exported:

- `id`
- `title`
- `created_time`
- `last_edited_time`
- `icon`
- `archived`
- `cover`

Example:

```yml
---
id: e42383cd-4975-4897-b967-ce453760499f
title: An amazing post
cover: https://img.bank.sh/an_image.jpg
created_time: 2022-01-23T12:31:00.000Z
last_edited_time: 2022-01-23T12:31:00.000Z
icon: 💥
archived: false
created_by_id: db313571-0280-411f-a6de-70e826421d16
created_by_object: user
last_edited_by_id: db313571-0280-411f-a6de-70e826421d16
last_edited_by_object: user
---
```

### Custom properties

Custom properties are also supported. Their names are [parameterized](https://api.rubyonrails.org/classes/ActiveSupport/Inflector.html#method-i-parameterize) and [underscored](https://api.rubyonrails.org/classes/ActiveSupport/Inflector.html#method-i-underscore) before being added to front matter.

For example, Notion properties named `Multiple Options` and `Tags` would become:

```yml
---
tags: tag1, tag2, tag3
multiple_options: option1, option2
---
```

Supported property types include:

- `number`
- `select`
- `multi_select`
- `date`
- `people`
- `files`
- `checkbox`
- `url`
- `email`
- `phone_number`
- `rich_text` (plain text only)

Advanced types such as `formula`, `relation`, and `rollup` are not supported. See the [Notion property value documentation](https://developers.notion.com/reference/property-value-object#all-property-values) for details.

## Testing

Run the test suite with:

```bash
rspec
```
