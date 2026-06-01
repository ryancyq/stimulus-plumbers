import { test, expect } from "@playwright/test";

test.beforeEach(async ({ page }) => {
  await page.goto("/form/choices");
  await page.waitForSelector("form");
});

// ── Choices Overview ─────────────────────────────────────────────────────

test.describe("choices overview", () => {
  test("default", async ({ page }) => {
    await expect(page.locator("#choices-default")).toHaveScreenshot(
      "choices-default.png",
    );
  });
});

// ── Single Checkbox ───────────────────────────────────────────────────────

test.describe("single checkbox", () => {
  test("unchecked", async ({ page }) => {
    await expect(page.locator("#single-checkbox-default")).toHaveScreenshot(
      "single-checkbox-unchecked.png",
    );
  });

  test("with hint", async ({ page }) => {
    await expect(page.locator("#single-checkbox-hint")).toHaveScreenshot(
      "single-checkbox-hint.png",
    );
  });

  test("checked", async ({ page }) => {
    await page
      .locator('#single-checkbox-default input[type="checkbox"]')
      .check();
    await expect(page.locator("#single-checkbox-default")).toHaveScreenshot(
      "single-checkbox-checked.png",
    );
  });
});

// ── Collection Checkbox ───────────────────────────────────────────────────

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
          .check();
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
          .check();
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
          .check();
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
          .check();
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
          .check();
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
          .check();
        await expect(
          page.locator("#collection-checkbox-card-stacked"),
        ).toHaveScreenshot("collection-checkbox-card-stacked-checked.png");
      });
    });
  });
});

// ── Collection Radio ──────────────────────────────────────────────────────

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
          .check();
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
          .check();
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
          .locator('#collection-radio-button-inline input[type="radio"]')
          .first()
          .check();
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
          .locator('#collection-radio-button-stacked input[type="radio"]')
          .first()
          .check();
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
          .locator('#collection-radio-card-inline input[type="radio"]')
          .first()
          .check();
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
          .locator('#collection-radio-card-stacked input[type="radio"]')
          .first()
          .check();
        await expect(
          page.locator("#collection-radio-card-stacked"),
        ).toHaveScreenshot("collection-radio-card-stacked-selected.png");
      });
    });
  });
});
