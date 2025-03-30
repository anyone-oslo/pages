import { create } from "zustand";

type Toast = {
  type: string;
  message: string;
};

type ToastState = {
  toasts: Toast[];
  error: (msg: string) => void;
  notice: (msg: string) => void;
  next: () => void;
};

const useToastStore = create<ToastState>((set) => ({
  toasts: [],
  error: (msg: string) =>
    set((state) => ({
      toasts: [...state.toasts, { message: msg, type: "error" }]
    })),
  notice: (msg: string) =>
    set((state) => ({
      toasts: [...state.toasts, { message: msg, type: "notice" }]
    })),
  next: () => set((state) => ({ toasts: state.toasts.slice(1) }))
}));

export default useToastStore;
