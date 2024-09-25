import { useCallback, MouseEvent, useEffect } from "react";

import useModalStore from "../stores/useModalStore";

export default function Modal() {
  const component = useModalStore((state) => state.component);
  const close = useModalStore((state) => state.close);

  const handleClose = useCallback(
    (evt: KeyboardEvent | MouseEvent) => {
      evt.stopPropagation();
      evt.preventDefault();
      close();
    },
    [close]
  );

  useEffect(() => {
    if (component) {
      document.body.classList.add("modal");
    } else {
      document.body.classList.remove("modal");
    }
  }, [component]);

  useEffect(() => {
    const handleKeypress = (evt: KeyboardEvent) => {
      if (component && (evt.key == "Escape" || evt.keyCode === 27)) {
        handleClose(evt);
      }
    };

    window.addEventListener("keypress", handleKeypress);
    return () => {
      window.removeEventListener("keypress", handleKeypress);
    };
  }, [component, handleClose]);

  if (component) {
    return (
      <div className="modal-wrapper open">
        <div className="background" onClick={handleClose} />
        <div className="modal">{component}</div>
      </div>
    );
  } else {
    return <div className="modal-wrapper"></div>;
  }
}
