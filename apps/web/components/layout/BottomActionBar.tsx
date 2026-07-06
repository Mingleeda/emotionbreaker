import type { ReactNode } from "react";

type BottomActionBarProps = {
  children: ReactNode;
};

export function BottomActionBar({ children }: BottomActionBarProps) {
  return <div className="sticky bottom-0 -mx-6 mt-auto bg-[#FBF8F4] px-6 py-4">{children}</div>;
}
