<img src="https://ik.imagekit.io/gxidvqvc9/noiton_to_md_logo_white_bg_-OiZSEkqY.png?updatedAt=1756209770491" width="150">

# notion_to_md

A Ruby library to export [Notion](https://www.notion.so/) pages and databases to Markdown.
The output is fully compliant with the [GitHub Flavored Markdown specification](https://github.github.com/gfm/).

[![Gem Version](https://badge.fury.io/rb/notion_to_md.svg)](https://badge.fury.io/rb/notion_to_md)
[![CI](https://github.com/emoriarty/notion_to_md/actions/workflows/ci.yml/badge.svg)](https://github.com/emoriarty/notion_to_md/actions)

> ⚠️ **Version notice:**
> You are reading the documentation for the latest development branch.
> For the stable **v2.x.x** documentation, see [the v2.x.x branch](https://github.com/emoriarty/notion_to_md/tree/v2.x.x).

## Installation

Install via RubyGems:

```bash
gem install notion_to_md
```

Or add it to your `Gemfile`:

```ruby
gem 'notion_to_md'
```

## Quick Start

```ruby
# Convert a Notion page to Markdown
md = NotionToMd.call(:page, id: 'b91d5...', token: ENV['NOTION_TOKEN'])
File.write("page.md", md)
```

## Usage

Before using the gem, create a Notion integration and obtain a secret token.
See the [Notion Getting Started Guide](https://developers.notion.com/docs/getting-started) for details.

### Pages

```ruby
md = NotionToMd.call(:page, id: 'b91d5...', token: 'secret_...')
# or equivalently
md = NotionToMd.convert(:page, id: 'b91d5...', token: 'secret_...')
```

`md` is a string containing the page content in Markdown format.

### Databases

```ruby
mds = NotionToMd.call(:database, id: 'b91d5...')
```

`mds` is an array of strings, one per page.

### Environment Variables

If your token is stored in `NOTION_TOKEN`, you don’t need to pass it explicitly:

```bash
export NOTION_TOKEN=<secret_...>
```

```ruby
md = NotionToMd.call(:page, id: 'b91d5...')
```

## Supported Blocks

Everything in Notion is a [block object](https://developers.notion.com/reference/block#block-object-keys).

| Block type                        | Nested children supported? |
|-----------------------------------|----------------------------|
| paragraph                         | ✅ |
| heading_1 / heading_2 / heading_3 | ❌ |
| bulleted_list_item                | ✅ |
| numbered_list_item                | ✅ |
| to_do                             | ✅ |
| image, file, pdf, video           | ❌ |
| bookmark, embed, link_preview     | ❌ |
| callout                           | ❌ |
| quote                             | ❌ |
| divider                           | ❌ |
| table                             | ❌ |
| code                              | ❌ |
| equation                          | ❌ |

## Front Matter

By default, front matter is **disabled**. Enable it with:

```ruby
NotionToMd.call(:page, id: 'b91d5...', frontmatter: true)
```

### Examples

**Default properties:**

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

**Custom properties:**

```yml
---
tags: tag1, tag2, tag3
multiple_options: option1, option2
---
```

Custom property names are [parameterized](https://api.rubyonrails.org/classes/ActiveSupport/Inflector.html#method-i-parameterize) and [underscored](https://api.rubyonrails.org/classes/ActiveSupport/Inflector.html#method-i-underscore).

Supported property types:

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

⚠️ Advanced types such as `formula`, `relation`, and `rollup` are **not supported**.
See the [Notion property value docs](https://developers.notion.com/reference/property-value-object#all-property-values).

## Development

Run the test suite with:

```bash
rspec
```
