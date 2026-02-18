import { create } from "zustand";

type ModalState = {
  component: React.ReactNode;
  open: (elem: React.ReactNode) => void;
  close: () => void;
};

const useModalStore = create<ModalState>((set) => ({
  component: null,
  open: (c: React.ReactNode) => set({ component: c }),
  close: () => set({ component: null })
}));

export default useModalStore;
