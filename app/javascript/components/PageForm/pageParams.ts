function dates(state: PageForm.State) {
  if (state.datesEnabled) {
    return {
      all_day: state.page.all_day,
      starts_at: state.page.starts_at,
      ends_at: state.page.ends_at
    };
  } else {
    return {
      all_day: false,
      starts_at: null,
      ends_at: null
    };
  }
}

export default function pageParams(state: PageForm.State) {
  const { page } = state;

  // meta_image_id
  // page_images
  // page_files
  return {
    ...dates(state),
    ...page.blocks,
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
