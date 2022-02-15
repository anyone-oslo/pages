class ResponsiveEmbeds {
  readyHandler(fn) {
    if (document.readyState === "complete" || document.readyState === "interactive") {
      setTimeout(fn, 1);
    } else {
      document.addEventListener("DOMContentLoaded", fn);
    }
  }

  wrapEmbeds() {
    let selectors = [ "iframe[src*=\"bandcamp.com\"]",
                      "iframe[src*=\"player.vimeo.com\"]",
                      "iframe[src*=\"youtube.com\"]",
                      "iframe[src*=\"youtube-nocookie.com\"]",
                      "iframe[src*=\"spotify.com\"]",
                      "iframe[src*=\"kickstarter.com\"][src*=\"video.html\"]" ];

    let embeds = Array.prototype.slice.call(
      document.querySelectorAll(selectors.join(","))
    );

    function wrapEmbed(embed) {
      const parent = embed.parentNode;

      // Recycle the existing container if the embed is already responsive.
      if (parent.tagName === "DIV" &&
          parent.childNodes.length === 1 &&
          parent.style.position === "relative") {
        return parent;
      }

      let wrapper = document.createElement("div");
      if (parent.tagName === "P") {
        parent.parentNode.replaceChild(wrapper, parent);
      } else {
        parent.replaceChild(wrapper, embed);
      }
      wrapper.appendChild(embed);
      return wrapper;
    }

    embeds.forEach(function (embed) {
      if (embed.parentNode &&
          embed.parentNode.classList.contains("responsive-embed")) {
        return;
      }

      let width = embed.offsetWidth;
      let height = embed.offsetHeight;
      let ratio = height / width;
      let wrapper = wrapEmbed(embed);

      wrapper.classList.add("responsive-embed");
      wrapper.style.position = "relative";
      wrapper.style.width = "100%";
      wrapper.style.paddingTop = 0;
      wrapper.style.paddingBottom = (ratio * 100) + "%";

      embed.style.position = "absolute";
      embed.style.width = "100%";
      embed.style.height = "100%";
      embed.style.top = "0";
      embed.style.left = "0";
    });
  }

  start() {
    this.readyHandler(() => this.wrapEmbeds());
  }
}

export default new ResponsiveEmbeds();
