import { test, expect } from "@playwright/test";

test.describe("modal form", () => {
  test("keeps the route directly navigable", async ({ page }) => {
    await page.goto("/components/modal/form");

    const root = page.locator("#modal-form");
    await expect(root).toBeVisible();
    await expect(
      root.getByRole("heading", { name: "Edit profile", level: 1 }),
    ).toBeVisible();
    await expect(root.locator("form#modal-form-fields")).toBeVisible();
    await expect(root.getByRole("button", { name: "Save" })).toBeVisible();

    await root.getByRole("button", { name: "Save" }).click();
    await expect(root.locator("form#modal-form-fields")).toBeVisible();
  });
});
