import { defineConfig } from "@playwright/test";
import base from "./playwright.base.js";

// The -u / --update-snapshots mode, attached (-uall, --update-snapshots=all) or as the next argument.
const updateMode = (argv) => {
  const flag = /^(-u|--update-snapshots(?=$|=))=?/;
  const index = argv.findIndex((arg) => flag.test(arg));
  if (index === -1) return null;
  const next = argv[index + 1];
  return (
    argv[index].replace(flag, "") ||
    (/^(all|changed|missing|none)$/.test(next) ? next : "changed")
  );
};

// An update run compares too; workers inherit SNAPSHOTS, not the flag. A --ui run needs SNAPSHOTS=compare.
const mode = updateMode(process.argv);
if (mode && mode !== "none") process.env.SNAPSHOTS = "compare";

export default defineConfig({
  ...base,
  testDir: "test/snapshots",
  // Committed baselines are Linux-only; other platforms compare pixels only when asked.
  ignoreSnapshots:
    !process.env.CI &&
    process.platform !== "linux" &&
    process.env.SNAPSHOTS !== "compare",
  snapshotDir: "test/snapshots/__snapshots__",

  // {testFilePath}, not {testFileName} — same-named specs in different dirs would collide.
  projects: base.projects.map((p) => ({
    ...p,
    snapshotPathTemplate: `{snapshotDir}/${p.metadata.form}/${p.metadata.device}/{platform}/{testFilePath}/{arg}{ext}`,
  })),
});
