import { useState } from "react";

export default function useMaybeControlledValue<T>(
  initialValue: T,
  onChange?: (nextValue: T) => void
): [T, (nextValue: T) => void] {
  const [value, setValue] = useState(initialValue);

  if (onChange) {
    return [initialValue, onChange];
  } else {
    return [value, setValue];
  }
}
