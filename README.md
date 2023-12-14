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

Since v2.3 you can also use the convenient `convert` method from the root module.

```ruby
require 'notion_to_md'

md = NotionToMd.convert(page_id: 'b91d5...', token: 'secret_...')
```

If the secret token is provided as an environment variable —`NOTION_TOKEN`—, there's no need to pass it as an argument to the constructor.

```bash
$ export NOTION_TOKEN=<secret_...>
```

```ruby
require 'notion_to_md'

notion_converter = NotionToMd::Converter.new(page_id: 'b91d5...')
md = notion_converter.convert
# or
md = NotionToMd.convert(page_id: 'b91d5...')
```

And that's all. The `md` is a string variable containing the notion page formatted in markdown.

## Blocks

Everything in a notion page body is a [block object](https://developers.notion.com/reference/block#block-object-keys). Therefore, not every type can be mapped to Markdown. Below there's a list of current supported blocks types.

* `paragraph`
* `heading_1`
* `heading_2`
* `heading_3`
* `bulleted_list_item`
* `numbered_list_item` (supported since v2.3, in previous versions is displayed as `bulleted_list_item`)
* `to_do`
* `image`
* `bookmark`
* `callout`
* `quote`
* `divider`
* `table`
* `embed`
* `code`

### Nested blocks

Starting with v2, nested blocks are supported. The permitted blocks to have children are:

* `paragraph`
* `bulleted_list_item`
* `numbered_list_item`
* `to_do`

## Front matter

From version 0.2.0, notion_to_md supports front matter in markdown files.

By default, the front matter section is not included to the document. To do so, provide the `:frontmatter` option set to `true` to `convert` method.

```ruby
NotionToMd::Converter.new(page_id: 'b91d5...').convert(frontmatter: tue)
# or
NotionToMd.convert(page_id: 'b91d5...', frontmatter: true) # Since v2.3
```

Default notion [properties](https://developers.notion.com/reference/page#all-pages) are page `id`, `title`, `created_time`, `last_edited_time`, `icon`, `archived` and `cover`.

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

In addition to default properties, custom properties are also supported.
Custom properties name is [parameterized](https://api.rubyonrails.org/classes/ActiveSupport/Inflector.html#method-i-parameterize) and [underscorized](https://api.rubyonrails.org/classes/ActiveSupport/Inflector.html#method-i-underscore) before added to front matter.
For example, two properties named `Multiple Options` and `Tags` will be transformed to `multiple_options` and `tags`, respectively.

```yml
---
tags: tag1, tag2, tag3
multiple_options: option1, option2
---
```

The supported property types are:

* `number`
* `select`
* `multi_select`
* `date`
* `people`
* `files`
* `checkbox`
* `url`
* `email`
* `phone_number`
* `rich_text`, supported but in plain text

Advanced types like `formula`, `relation` and `rollup` are not supported.

Check notion documentation about [property values](https://developers.notion.com/reference/property-value-object#all-property-values) to know more.

## Test
```bash
rspec
```
