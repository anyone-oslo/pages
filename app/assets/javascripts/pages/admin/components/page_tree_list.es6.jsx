class PageTreeList extends React.Component {
  render () {
    var pages = this.props.pages;
    return (
      <ul>
        {pages.map(function (page) {
           return <PageTreeNode page={page} />
         })}
      </ul>
    )
  }
}
