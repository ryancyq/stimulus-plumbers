import { test, expect } from "@playwright/test";

test.beforeEach(async ({ page }) => {
  await page.goto("/form/collection_checkbox");
  await page.waitForSelector("form");
});

test.describe("collection checkbox", () => {
  test.describe("default", () => {
    test.describe("inline", () => {
      test("unchecked", async ({ page }) => {
        await expect(
          page.locator("#collection-checkbox-default-inline"),
        ).toHaveScreenshot("collection-checkbox-default-inline-unchecked.png");
      });

      test("checked", async ({ page }) => {
        await page
          .locator('#collection-checkbox-default-inline input[type="checkbox"]')
          .first()
          .locator("xpath=ancestor::label")
          .click();
        await expect(
          page.locator("#collection-checkbox-default-inline"),
        ).toHaveScreenshot("collection-checkbox-default-inline-checked.png");
      });
    });

    test.describe("stacked", () => {
      test("unchecked", async ({ page }) => {
        await expect(
          page.locator("#collection-checkbox-default-stacked"),
        ).toHaveScreenshot("collection-checkbox-default-stacked-unchecked.png");
      });

      test("checked", async ({ page }) => {
        await page
          .locator(
            '#collection-checkbox-default-stacked input[type="checkbox"]',
          )
          .first()
          .locator("xpath=ancestor::label")
          .click();
        await expect(
          page.locator("#collection-checkbox-default-stacked"),
        ).toHaveScreenshot("collection-checkbox-default-stacked-checked.png");
      });
    });
  });

  test.describe("button", () => {
    test.describe("inline", () => {
      test("unchecked", async ({ page }) => {
        await expect(
          page.locator("#collection-checkbox-button-inline"),
        ).toHaveScreenshot("collection-checkbox-button-inline-unchecked.png");
      });

      test("checked", async ({ page }) => {
        await page
          .locator('#collection-checkbox-button-inline input[type="checkbox"]')
          .first()
          .locator("xpath=ancestor::label")
          .click();
        await expect(
          page.locator("#collection-checkbox-button-inline"),
        ).toHaveScreenshot("collection-checkbox-button-inline-checked.png");
      });
    });

    test.describe("stacked", () => {
      test("unchecked", async ({ page }) => {
        await expect(
          page.locator("#collection-checkbox-button-stacked"),
        ).toHaveScreenshot("collection-checkbox-button-stacked-unchecked.png");
      });

      test("checked", async ({ page }) => {
        await page
          .locator('#collection-checkbox-button-stacked input[type="checkbox"]')
          .first()
          .locator("xpath=ancestor::label")
          .click();
        await expect(
          page.locator("#collection-checkbox-button-stacked"),
        ).toHaveScreenshot("collection-checkbox-button-stacked-checked.png");
      });
    });
  });

  test.describe("card", () => {
    test.describe("inline", () => {
      test("unchecked", async ({ page }) => {
        await expect(
          page.locator("#collection-checkbox-card-inline"),
        ).toHaveScreenshot("collection-checkbox-card-inline-unchecked.png");
      });

      test("checked", async ({ page }) => {
        await page
          .locator('#collection-checkbox-card-inline input[type="checkbox"]')
          .first()
          .locator("xpath=ancestor::label")
          .click();
        await expect(
          page.locator("#collection-checkbox-card-inline"),
        ).toHaveScreenshot("collection-checkbox-card-inline-checked.png");
      });
    });

    test.describe("stacked", () => {
      test("unchecked", async ({ page }) => {
        await expect(
          page.locator("#collection-checkbox-card-stacked"),
        ).toHaveScreenshot("collection-checkbox-card-stacked-unchecked.png");
      });

      test("checked", async ({ page }) => {
        await page
          .locator('#collection-checkbox-card-stacked input[type="checkbox"]')
          .first()
          .locator("xpath=ancestor::label")
          .click();
        await expect(
          page.locator("#collection-checkbox-card-stacked"),
        ).toHaveScreenshot("collection-checkbox-card-stacked-checked.png");
      });
    });
  });

  test.describe("error", () => {
    test("collection checkbox — error", async ({ page }) => {
      await expect(page.locator("#collection-checkbox-error")).toHaveScreenshot(
        "collection-checkbox-error.png",
      );
    });
  });
});
