import type { ReactNode } from "react";

type AppShellProps = {
  children: ReactNode;
};

export function AppShell({ children }: AppShellProps) {
  return <div className="mx-auto min-h-screen w-full max-w-3xl px-6 py-8">{children}</div>;
}
