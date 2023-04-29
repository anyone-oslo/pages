export default function pageParams(page: PageResource) {
  // meta_image_id
  // page_images
  // page_files
  return {
    ...page.blocks,
    starts_at: page.starts_at,
    ends_at: page.ends_at,
    all_day: page.all_day,
    status: page.status,
    published_at: page.published_at,
    pinned: page.pinned,
    template: page.template,
    unique_name: page.unique_name,
    feed_enabled: page.feed_enabled,
    news_page: page.news_page,
    user_id: page.user_id,
    redirect_to: page.redirect_to,
    serialized_tags: JSON.stringify(page.enabled_tags),
    path_segment: page.path_segment
  };
}
