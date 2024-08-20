import React from "react";

type Props = {
  label: string;
  icon: string;
  className: string;
  onClick: (evt: React.MouseEvent) => void;
};

export default function Button({ label, icon, className, onClick }: Props) {
  const iconClass = "fa-solid fa-" + icon + " icon";

  const preventDrag = (evt: React.MouseEvent) => {
    evt.stopPropagation();
  };

  return (
    <button
      type="button"
      className={className}
      onClick={onClick}
      onMouseDown={preventDrag}>
      <i className={iconClass} />
      {label}
    </button>
  );
}
