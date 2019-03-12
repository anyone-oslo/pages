$(function() {
  $('textarea.rich').each(function () {
    let container = document.createElement("div");
    this.parentNode.appendChild(container);
    ReactDOM.render(
      <RichTextArea value={this.value}
                    name={this.name}
                    rows={this.rows}
                    id={this.id} />,
      container
    );
    this.parentNode.removeChild(this);
  });
});
