import { useCallback, useState } from "react";
import * as Crop from "../../types/Crop";

export default function useContainerSize(): [
  (node?: HTMLDivElement) => void,
  Crop.Size
] {
  const [containerSize, setContainerSize] = useState<Crop.Size>();

  const ref = useCallback((node?: HTMLDivElement) => {
    const measure = () => {
      setContainerSize({
        width: node.offsetWidth - 2,
        height: node.offsetHeight - 2
      });
    };
    if (node !== null) {
      measure();
      const observer = new ResizeObserver(measure);
      observer.observe(node);
    }
  }, []);

  return [ref, containerSize];
}
