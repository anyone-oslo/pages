class PageTree extends React.Component {
  render () {
    var pages = this.props.pages;
    return (
      <div className="page-tree">
        <PageTreeList pages={pages} />
      </div>
    )
  }
}
