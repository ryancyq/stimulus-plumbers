import { test, expect } from "@playwright/test";

test.describe("turbo popover", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/components/popover/turbo");
    await page.waitForSelector("#popover-turbo [data-controller='popover']");
  });

  test("lazy-loads the frame when the panel opens", async ({ page }) => {
    const root = page.locator("#popover-turbo");
    const panel = root.locator("#popover-turbo-panel");

    await root.getByRole("button", { name: "Load remote content" }).click();
    await expect(panel).toBeVisible();
    await expect(
      panel.getByRole("heading", { name: "Remote popover content" }),
    ).toBeVisible();
  });

  test("reconnects when a Turbo Stream replaces the panel", async ({
    page,
  }) => {
    const root = page.locator("#popover-turbo");
    const source = root.getByRole("button", { name: "Replace panel content" });
    const panel = root.locator("#popover-replacement-panel");
    const initialPanel = await panel.elementHandle();

    await source.click();
    await panel.getByRole("link", { name: "Replace panel" }).click();
    await expect(panel.locator("#popover-replacement-status")).toHaveText(
      "The panel target was replaced by a matching Turbo Stream.",
    );
    expect(await initialPanel.evaluate((element) => element.isConnected)).toBe(
      false,
    );

    await page.keyboard.press("Escape");
    await expect(panel).not.toBeVisible();
    await source.click();
    await expect(panel).toBeVisible();
  });

  test("restores a closed panel from the Turbo cache", async ({ page }) => {
    const root = page.locator("#popover-turbo");
    const panel = root.locator("#popover-turbo-panel");

    await root.getByRole("button", { name: "Load remote content" }).click();
    await expect(panel).toBeVisible();
    await root.getByRole("link", { name: "Navigate away" }).click();
    await expect(page).toHaveURL(/\/components\/controls\/button$/);
    await page.goBack();
    await expect(page).toHaveURL(/\/components\/popover\/turbo$/);
    await expect(page.locator("#popover-turbo-panel")).not.toBeVisible();
  });
});
