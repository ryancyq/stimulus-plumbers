import { test, expect } from "@playwright/test";

test.describe("modal form", () => {
  test("keeps the route directly navigable", async ({ page }) => {
    await page.goto("/components/modal/form");

    const container = page.locator("#modal-form");
    await expect(container).toBeVisible();
    await expect(
      container.getByRole("heading", { name: "Edit profile", level: 1 }),
    ).toBeVisible();
    await expect(container.locator("form#modal-form-fields")).toBeVisible();
    await expect(container.getByRole("button", { name: "Save" })).toBeVisible();

    await container.getByRole("button", { name: "Save" }).click();
    await expect(container.locator("form#modal-form-fields")).toBeVisible();
  });
});
