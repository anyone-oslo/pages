import { createContext, useContext } from "react";
import * as PageEditor from "../../types/PageEditor";

export const PageFormContext = createContext<PageEditor.Context>(null);

export default function usePageFormContext() {
  return useContext(PageFormContext);
}
