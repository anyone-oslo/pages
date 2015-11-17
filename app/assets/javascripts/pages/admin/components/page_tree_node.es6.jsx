class PageTreeNode extends React.Component {
  subpages () {
    var pages = this.props.page.pages;
    if (pages.length > 0) {
      return <PageTreeList pages={pages} />
    }
  }

  url () {
    return(`/admin/${this.props.page.locale}/pages/${this.props.page.param}/edit`)
  }

  render () {
    var page = this.props.page;
    var subpages = this.subpages();
    return (
      <li>
        <div className="page">
          <a href={this.url()}>
            {page.name}
          </a>
        </div>
        {subpages}
      </li>
    )
  }
}
