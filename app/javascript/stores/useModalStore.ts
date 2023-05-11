import { create } from "zustand";

interface ModalState {
  component: JSX.Element | null;
  open: (elem: JSX.Element) => void;
  close: () => void;
}

const useModalStore = create<ModalState>((set) => ({
  component: null,
  open: (c: JSX.Element) => set({ component: c }),
  close: () => set({ component: null })
}));

export default useModalStore;
