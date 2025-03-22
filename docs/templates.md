# Templates

Every page has an associated template. A template consists of a template file (located in `app/views/pages/templates`), optionally a configuration and/or a controller action.

## Configuration

The installer will generate a default configuration in `config/initializers/page_templates.rb`. [See the template here](../lib/rails/generators/pages_core/install/templates/page_templates_initializer.rb). For a description of the valid options, see the [PagesCore::Templates::Configuration documentation](../lib/pages_core/templates/configuration.rb).

### Blocks

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

