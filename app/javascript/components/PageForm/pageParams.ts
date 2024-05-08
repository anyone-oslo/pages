interface Options {
  files: Attachments.State;
  images: ImageGrid.State;
  tags: TagEditor.State;
}

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

function pageFiles(state: Attachments.State) {
  const files = state.collection.draggables
    .filter((r) => r !== "Files")
    .map((r: Drag.Draggable<AttachmentRecord>, i: number) => {
      const a = r.record;
      return { id: a.id, attachment_id: a.attachment.id, position: i + 1 };
    });
  const deleted = state.deleted.map((a) => {
    return { id: a.id, attachment_id: a.attachment.id, _destroy: "true" };
  });
  return [...files, ...deleted];
}

function pageImages(state: ImageGrid.State) {
  const primary = state.primary.draggables
    .filter((r) => r !== "Files")
    .map((r: Drag.Draggable<ImageRecord>, i: number) => {
      const pi = r.record;
      return {
        id: pi.id,
        image_id: pi.image.id,
        primary: true,
        position: i + 1
      };
    });
  const images = state.images.draggables
    .filter((r) => r !== "Files")
    .map((r: Drag.Draggable<ImageRecord>, i: number) => {
      const pi = r.record;
      return {
        id: pi.id,
        image_id: pi.image.id,
        primary: false,
        position: primary.length + i + 1
      };
    });

  const deleted = state.deleted.map((i) => {
    return { id: i.id, image_id: i.image.id, _destroy: "true" };
  });
  return [...primary, ...images, ...deleted];
}

export default function pageParams(state: PageForm.State, options: Options) {
  const { files, images, tags } = options;
  const { page } = state;

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
    serialized_tags: JSON.stringify(tags.enabled),
    path_segment: page.path_segment,
    meta_image_id: page.meta_image.image && page.meta_image.image.id,
    parent_page_id: page.parent_page_id,
    page_files_attributes: pageFiles(files),
    page_images_attributes: pageImages(images)
  };
}
