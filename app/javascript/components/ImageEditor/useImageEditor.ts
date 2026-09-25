import { useReducer } from "react";
import * as Images from "../../types/Images";
import { Locale, LocalizedValue } from "../../types";

export type Action =
  | {
      type: "setAlternative" | "setCaption" | "setLocale";
      payload: string;
    }
  | { type: "setDecorative"; payload: boolean };

export type State = {
  locale: string;
  caption: LocalizedValue;
  alternative: LocalizedValue;
  decorative: boolean;
};

export type Options = {
  caption: boolean;
  image: Images.Resource;
  locales: Record<string, Locale>;
};

type Props = {
  caption: boolean;
  locale: string;
  locales: Record<string, Locale>;
  image: Images.Resource;
};

function reducer(state: State, action: Action): State {
  switch (action.type) {
    case "setAlternative":
      return {
        ...state,
        alternative: { ...state.alternative, [state.locale]: action.payload }
      };
    case "setCaption":
      return {
        ...state,
        caption: { ...state.caption, [state.locale]: action.payload }
      };
    case "setDecorative":
      return { ...state, decorative: action.payload };
    case "setLocale":
      return { ...state, locale: action.payload };
  }
}

export default function useImageEditor({
  caption,
  locale,
  locales,
  image
}: Props): [State, React.Dispatch<Action>, Options] {
  const [state, dispatch] = useReducer(reducer, {
    locale: locale,
    caption: image.caption || {},
    alternative: image.alternative || {},
    decorative: image.decorative || false
  });
  const options = {
    caption: caption,
    locales: locales,
    image: image
  };
  return [state, dispatch, options];
}
