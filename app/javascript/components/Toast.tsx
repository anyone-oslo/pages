import React, { useEffect, useRef, useState } from "react";

import useToastStore from "../stores/useToastStore";

interface Props {
  error: string;
  notice: string;
}

export default function Toast(props: Props) {
  const [fadeout, setFadeout] = useState(false);
  const { toasts, error, notice, next } = useToastStore((state) => state);
  const timerRef = useRef<ReturnType<typeof setTimeout>>(null);

  const toast = toasts[0];

  useEffect(() => {
    if (props.error) {
      error(props.error);
    }
    if (props.notice) {
      notice(props.notice);
    }
  }, [props.error, props.notice, error, notice]);

  useEffect(() => {
    setFadeout(false);
    if (toast && !timerRef.current) {
      timerRef.current = setTimeout(() => {
        setFadeout(true);
        timerRef.current = setTimeout(() => {
          timerRef.current = null;
          setFadeout(false);
          next();
        }, 500);
      }, 4000);
    }
    return () => {
      clearTimeout(timerRef.current);
    };
  }, [toast, next]);

  const classNames = ["toast"];

  if (toast) {
    classNames.push(toast.type);
    if (fadeout) {
      classNames.push("fadeout");
    }
  }

  return (
    <div className="toast-wrapper" aria-live="polite">
      {toast && <div className={classNames.join(" ")}>{toast.message}</div>}
    </div>
  );
}
