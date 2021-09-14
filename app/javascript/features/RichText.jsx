import React from "react";
import ReactDOM from "react-dom";
import RichTextArea from "../components/RichTextArea";
import readyHandler from "../lib/readyHandler";

class RichText {
  apply () {
    const elems = document.querySelectorAll("textarea.rich");
    elems.forEach((elem) => {
      this.enhance(elem);
    });
  }

  enhance (elem) {
    const container = document.createElement("div");
    elem.parentNode.appendChild(container);
    ReactDOM.render(
      <RichTextArea value={elem.value}
                    name={elem.name}
                    rows={elem.rows}
                    id={elem.id} />,
      container
    );
    elem.parentNode.removeChild(elem);
  }

  start () {
    readyHandler.ready(() => {
      this.apply();
    });
  }
}

export default new RichText();
