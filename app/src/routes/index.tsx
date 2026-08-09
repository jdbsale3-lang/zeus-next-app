import { createFileRoute } from "@tanstack/react-router";
import { CommandCenterLayout } from "@/layouts/command-center";

export const Route = createFileRoute("/")({
  component: Index,
});

function Index() {
  return <CommandCenterLayout />;
}
