class PageImages extends React.Component {
  render() {
    return (
      <div className="page-images">
        <GridImages attribute="page[page_images_attributes]"
                    primaryAttribute="page[image_id]"
                    enablePrimary={true}
                    showEmbed={true}
                    locale={this.props.locale}
                    locales={this.props.locales}
                    csrf_token={this.props.csrf_token}
                    records={this.props.records} />
      </div>
    );
  }
}
