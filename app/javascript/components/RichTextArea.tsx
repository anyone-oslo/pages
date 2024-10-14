import { useRef, ChangeEvent } from "react";
import ToolbarButton from "./RichTextArea/ToolbarButton";
import useMaybeControlledValue from "./RichTextArea/useMaybeControlledValue";

import {
  ActionFn,
  simpleActions,
  advancedActions
} from "./RichTextArea/actions";

type Props = {
  id: string;
  name: string;
  value: string;
  rows?: number;
  className?: string;
  simple?: boolean;
  lang?: string;
  dir?: string;
  onChange?: (str: string) => void;
};

export default function RichTextArea({
  id,
  name,
  value: initialValue,
  rows,
  className,
  simple,
  lang,
  dir,
  onChange
}: Props) {
  const [value, setValue] = useMaybeControlledValue(initialValue, onChange);

  const inputRef = useRef<HTMLTextAreaElement>(null);

  const actions = simple
    ? simpleActions
    : [...simpleActions, ...advancedActions];

  const applyAction = (fn: ActionFn) => {
    const [prefix, replacement, postfix] = fn(getSelection());
    replaceSelection(prefix, replacement, postfix);
  };

  const getSelection = (): string => {
    const textarea = inputRef.current;
    const { selectionStart, selectionEnd, value } = textarea;
    return value.substring(selectionStart, selectionEnd);
  };

  const handleChange = (evt: ChangeEvent<HTMLTextAreaElement>) => {
    setValue(evt.target.value);
  };

  const handleKeyPress = (evt: React.KeyboardEvent) => {
    let key: string;
    if (evt.key >= "A" && evt.key <= "Z") {
      key = evt.key.toLowerCase();
    } else if (evt.key === "Enter") {
      key = "enter";
    }

    const hotkeys: Record<string, ActionFn> = {};
    actions.forEach((a) => {
      if (a.hotkey) {
        hotkeys[a.hotkey] = a.fn;
      }
    });

    if ((evt.metaKey || evt.ctrlKey) && key in hotkeys) {
      evt.preventDefault();
      applyAction(hotkeys[key]);
    }
  };

  const localeOptions = () => {
    const opts: React.HTMLProps<HTMLTextAreaElement> = {};

    if (lang) {
      opts.lang = lang;
    }

    if (dir) {
      opts.dir = dir;
    }

    return opts;
  };

  const replaceSelection = (
    prefix: string,
    replacement: string,
    postfix: string
  ) => {
    const textarea = inputRef.current;
    const { selectionStart, selectionEnd, value } = textarea;

    textarea.value =
      value.substring(0, selectionStart) +
      prefix +
      replacement +
      postfix +
      value.substring(selectionEnd);

    textarea.focus({ preventScroll: true });
    textarea.setSelectionRange(
      selectionStart + prefix.length,
      selectionStart + prefix.length + replacement.length
    );
    setValue(textarea.value);
  };

  const clickHandler = (fn: ActionFn) => (evt: React.MouseEvent) => {
    evt.preventDefault();
    applyAction(fn);
  };

  return (
    <div className="rich-text-area">
      <div className="rich-text toolbar">
        {actions.map((action) => (
          <ToolbarButton
            key={action.name}
            name={action.name}
            className={action.className}
            onClick={clickHandler(action.fn)}
          />
        ))}
      </div>
      <textarea
        className={className || "rich"}
        ref={inputRef}
        id={id}
        name={name}
        value={value || ""}
        rows={rows || 5}
        onChange={handleChange}
        onKeyDown={handleKeyPress}
        {...localeOptions()}
      />
    </div>
  );
}
