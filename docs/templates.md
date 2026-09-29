# Templates

Every page has an associated template. A template consists of a template file (located in `app/views/pages/templates`), optionally a configuration and/or a controller action.

## Configuration

The installer will generate a default configuration in `config/initializers/page_templates.rb`. [See the template here](../lib/rails/generators/pages_core/install/templates/page_templates_initializer.rb). For a description of the valid options, see the [PagesCore::Templates::Configuration documentation](../lib/pages_core/templates/configuration.rb).

### Blocks

### Rich text editor

Text blocks are edited as Textile by default. `text_filter :document`
switches the text blocks of a template to the rich text editor, either for
all templates or for one:

``` ruby
config.default do |default|
  default.text_filter :document
end

config.template(:article) do |t|
  t.text_filter :document
end
```

`size: :field` blocks stay single-line inputs, and metadata blocks stay
Textile. `format: :inline` limits a block to paragraphs with bold, italic,
superscript and links, which suits standfirsts and bylines:

``` ruby
block.excerpt("Standfirst", format: :inline)
```

The HTML block button, "Show stored source" and pasted tables, scripts and
embed code are off by default. `html: true` turns them on for a block. The
first argument is the block title, so repeat the current one:

``` ruby
block.body("Body", html: true)
```

See [Text formatting](text-formatting.md#rich-text-editor) for how the text
is stored.

#### Before switching an existing site

Existing Textile is converted when a block is opened in the editor, and
stored as HTML the first time the block is edited and the page saved. There
is no conversion back to Textile.

1. Export the pages first with `bin/rails pages:export:pages`, and keep the
   `export/` directory.
2. Find views, helpers and resources that print `excerpt`, `body` or other
   text blocks without `.to_html` (e.g. `<%= @page.excerpt %>`,
   `strip_tags(page.excerpt)`, JSON resources). They would show the stored
   HTML as text.
3. Find code that post-processes rendered text with Nokogiri or regular
   expressions, and check it against the new markup.
4. Update specs that compare against the stored value, such as
   `have_text(page.body)` in the generated `spec/system/page_templates_spec.rb`.
5. Sites that build their own `app/assets/builds/admin.js` from the
   `@anyone-oslo/pages` npm package need a version with the editor, matching
   the `pages_core` gem version.

## Controller

``` ruby
class PagesController < PagesCore::Frontend::PagesController
  template(:employees) do |page|
    @employees = page.pages.paginate(per_page: 12, page: page_param)
  end
  
  template(:employee) do |page|
    if page.parent
      redirect_to page_url(locale, page.parent)
    else
      redirect_to root_url
    end
  end
end
```

