import { test, expect } from "@playwright/test";

test.beforeEach(async ({ page }) => {
  await page.goto("/form/collection_radio");
  await page.waitForSelector("form");
});

test.describe("collection radio", () => {
  test.describe("default", () => {
    test.describe("inline", () => {
      test("unselected", async ({ page }) => {
        await expect(
          page.locator("#collection-radio-default-inline"),
        ).toHaveScreenshot("collection-radio-default-inline-unselected.png");
      });

      test("selected", async ({ page }) => {
        await page
          .locator('#collection-radio-default-inline input[type="radio"]')
          .first()
          .locator("xpath=ancestor::label")
          .click();
        await expect(
          page.locator("#collection-radio-default-inline"),
        ).toHaveScreenshot("collection-radio-default-inline-selected.png");
      });
    });

    test.describe("stacked", () => {
      test("unselected", async ({ page }) => {
        await expect(
          page.locator("#collection-radio-default-stacked"),
        ).toHaveScreenshot("collection-radio-default-stacked-unselected.png");
      });

      test("selected", async ({ page }) => {
        await page
          .locator('#collection-radio-default-stacked input[type="radio"]')
          .first()
          .locator("xpath=ancestor::label")
          .click();
        await expect(
          page.locator("#collection-radio-default-stacked"),
        ).toHaveScreenshot("collection-radio-default-stacked-selected.png");
      });
    });
  });

  test.describe("button", () => {
    test.describe("inline", () => {
      test("unselected", async ({ page }) => {
        await expect(
          page.locator("#collection-radio-button-inline"),
        ).toHaveScreenshot("collection-radio-button-inline-unselected.png");
      });

      test("selected", async ({ page }) => {
        await page
          .locator("#collection-radio-button-inline label")
          .first()
          .click();
        await expect(
          page.locator("#collection-radio-button-inline"),
        ).toHaveScreenshot("collection-radio-button-inline-selected.png");
      });
    });

    test.describe("stacked", () => {
      test("unselected", async ({ page }) => {
        await expect(
          page.locator("#collection-radio-button-stacked"),
        ).toHaveScreenshot("collection-radio-button-stacked-unselected.png");
      });

      test("selected", async ({ page }) => {
        await page
          .locator("#collection-radio-button-stacked label")
          .first()
          .click();
        await expect(
          page.locator("#collection-radio-button-stacked"),
        ).toHaveScreenshot("collection-radio-button-stacked-selected.png");
      });
    });
  });

  test.describe("card", () => {
    test.describe("inline", () => {
      test("unselected", async ({ page }) => {
        await expect(
          page.locator("#collection-radio-card-inline"),
        ).toHaveScreenshot("collection-radio-card-inline-unselected.png");
      });

      test("selected", async ({ page }) => {
        await page
          .locator("#collection-radio-card-inline label")
          .first()
          .click();
        await expect(
          page.locator("#collection-radio-card-inline"),
        ).toHaveScreenshot("collection-radio-card-inline-selected.png");
      });
    });

    test.describe("stacked", () => {
      test("unselected", async ({ page }) => {
        await expect(
          page.locator("#collection-radio-card-stacked"),
        ).toHaveScreenshot("collection-radio-card-stacked-unselected.png");
      });

      test("selected", async ({ page }) => {
        await page
          .locator("#collection-radio-card-stacked label")
          .first()
          .click();
        await expect(
          page.locator("#collection-radio-card-stacked"),
        ).toHaveScreenshot("collection-radio-card-stacked-selected.png");
      });
    });
  });

  test.describe("error", () => {
    test("collection radio — error", async ({ page }) => {
      await expect(page.locator("#collection-radio-error")).toHaveScreenshot(
        "collection-radio-error.png",
      );
    });
  });

  test.describe("card variants", () => {
    test("all variants selected", async ({ page }) => {
      await expect(
        page.locator("#collection-radio-card-variants"),
      ).toHaveScreenshot("card-variants.png");
    });
  });
});
