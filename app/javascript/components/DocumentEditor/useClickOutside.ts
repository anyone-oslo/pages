import { useEffect, useRef, type RefObject } from "react";

/**
 * Calls onOutside on mousedown outside ref while active. Node view
 * popovers use it to close; pass active=false while a modal picker is up.
 *
 * The listener is attached on the next macrotask so the mousedown that
 * opened the popover (toolbar Link / Email / Video) does not close it.
 */
export default function useClickOutside(
  ref: RefObject<HTMLElement | null>,
  active: boolean,
  onOutside: () => void
) {
  const onOutsideRef = useRef(onOutside);
  onOutsideRef.current = onOutside;

  useEffect(() => {
    if (!active) return;
    const onMouseDown = (e: MouseEvent) => {
      if (!ref.current?.contains(e.target as Node)) onOutsideRef.current();
    };
    const id = window.setTimeout(() => {
      document.addEventListener("mousedown", onMouseDown);
    }, 0);
    return () => {
      window.clearTimeout(id);
      document.removeEventListener("mousedown", onMouseDown);
    };
  }, [ref, active]);
}
