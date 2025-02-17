# Caching

All pages are statically cached by default. There are two levels of cache: non-permanent items are expired whenever a model is saved. Permanent items are cached indefinetely. The latter is useful for things like images, where the signed URL changes when the image is changed.

Expiring the cache can be done using the following tasks:

``` shell
bin/rails pages:cache:sweep 
bin/rails pages:cache:purge # Purge the entire cache, including permanent items
```

This should be performed after deployment.

## Using the cache with your own models and controller

Caching is enabled with the `static_cache` helper:

``` ruby
class WidgetsController < FrontendController
  static_cache :index, :show, permanent: false
end
```

Enabling the static cache will disable sessions.

Include the `PagesCore::Sweepable` module in your model to enable automatic cache sweeping. The sweep will be performed in the background using ActiveJob.

``` ruby
model Widget
  include PagesCore::Sweepable
end
```

Bulk updates can trigger a cascade of queued sweep jobs. To prevent this, use the `PagesCore::CacheSweeper.once` helper:

``` ruby
PagesCore::CacheSweeper.once do
  Widget.find_each { |w| w.update(attributes) }
end
```

## Skipping the cache

Caching can be skipped for any request using the `disable_static_cache!` helper.

``` ruby
class PagesController < PagesCore::Frontend::PagesController
  template(:my_template) do |page|
    disable_static_cache!
  end
end

```

## Cache adapters

The cache handler can be configured using `PagesCore.config.static_cache_handler`. If not configured, the default will be either `VarnishHandler` or `PageCacheHandler`, depending on if `ENV["VARNISH_URL"]` is set.

### VarnishHandler

If the Varnish handler is enabled, the `X-Cache-Tags` header will be set to `static` or `permanent` for responses that should be cached. The cache will be expired with a BAN HTTP request to `ENV["VARNISH_URL"]`. 

### PageCacheHandler

This handler uses [actionpack-page_caching](https://github.com/rails/actionpack-page_caching).

### NullHandler

This handler does nothing, effectively disabling the static cache.
