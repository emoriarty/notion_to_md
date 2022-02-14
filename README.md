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


### Front matter

From version 0.2.0, notion_to_md supports front matter in markdown files.

By default, the front matter section is not included to the document. To do so, provide the `:frontmatter` option set to `true` to `convert` method.

```ruby
NotionToMd::Converter.new(page_id: 'b91d5...').convert(frontmatter: tue)
```

Default notion properties are page `id`, `title`, `created_time`, `last_edited_time`, `icon`, `archived` and `cover`.

```yml
---
id: e42383cd-4975-4897-b967-ce453760499f
title: An amazing post
cover: https://img.bank.sh/an_image.jpg
created_time: 2022-01-23T12:31:00.000Z
last_edited_time: 2022-01-23T12:31:00.000Z
icon: 💥
archived: false
---
```

In addition to default properties, custom properties are also supported.
Custom properties are included by using the property name [parameterized](https://api.rubyonrails.org/classes/ActiveSupport/Inflector.html#method-i-parameterize) and [underscorized](https://api.rubyonrails.org/classes/ActiveSupport/Inflector.html#method-i-underscore) as key.
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

`rich_text` as advanced types like `formula`, `relation` and `rollup` are not supported.

Check notion documentation about [property values](https://developers.notion.com/reference/property-value-object#all-property-values) to know more.

## Test
```bash
rspec
```
