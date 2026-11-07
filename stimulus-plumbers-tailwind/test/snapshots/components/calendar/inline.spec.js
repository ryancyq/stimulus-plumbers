import { test, expect } from "@playwright/test";

const visit = async (page, query = "") => {
  await page.goto(`/components/calendar/inline${query}`);
  await page.waitForSelector("#calendar-inline-decade [data-date]");
};

// The frame request for another period of #calendar-month.
const monthRequest = (url) => url.searchParams.has("calendar-month[displayed]");

const focusDay = (section, date) =>
  section.locator(`[data-date='${date}']`).focus();

const navigation = (section, name) =>
  section.locator(`[data-navigation='${name}']`);

// Both modes match the same baselines.
for (const mode of ["stimulus", "turbo"]) {
  test.describe(`${mode} mode`, () => {
    test.beforeEach(({ page }) =>
      visit(page, mode === "turbo" ? "?navigation=turbo" : ""),
    );

    test.describe("calendar — month", () => {
      test("default", async ({ page }) => {
        await expect(page.locator("#calendar-inline-month")).toHaveScreenshot(
          "month-default.png",
        );
      });

      test("arrow keys move focus", async ({ page }) => {
        const section = page.locator("#calendar-inline-month");
        await focusDay(section, "2026-09-15");
        await page.keyboard.press("ArrowRight");
        await expect(section.locator("[data-date='2026-09-16']")).toBeFocused();
        await expect(section).toHaveScreenshot("month-focused.png");
      });

      test("Enter selects the focused day", async ({ page }) => {
        const section = page.locator("#calendar-inline-month");
        await focusDay(section, "2026-09-15");
        await page.keyboard.press("ArrowRight");
        await page.keyboard.press("Enter");
        await expect(
          section.locator("td[aria-selected='true'] [data-date='2026-09-16']"),
        ).toBeVisible();
        await expect(section).toHaveScreenshot("month-selected.png");
      });

      test("next month", async ({ page }) => {
        const section = page.locator("#calendar-inline-month");
        await navigation(section, "next").click();
        await expect(
          section.getByRole("heading", { level: 2, name: "October 2026" }),
        ).toBeVisible();
        await expect(section).toHaveScreenshot("month-next.png");
      });

      test("Page Down moves focus into the next month", async ({ page }) => {
        const section = page.locator("#calendar-inline-month");
        await focusDay(section, "2026-09-15");
        await page.keyboard.press("PageDown");
        await expect(section.locator("[data-date='2026-10-15']")).toBeFocused();
        await expect(section).toHaveScreenshot("month-page-down.png");
      });

      test("zoomed out to the year", async ({ page }) => {
        const section = page.locator("#calendar-inline-month");
        await navigation(section, "zoom").click();
        await expect(
          section.locator("[role='grid'][data-view='year']"),
        ).toBeVisible();
        await expect(section).toHaveScreenshot("month-zoomed-out.png");
      });
    });

    test.describe("calendar — other views", () => {
      test("adjacent month days", async ({ page }) => {
        await expect(
          page.locator("#calendar-inline-other-months"),
        ).toHaveScreenshot("other-months-default.png");
      });

      test("year", async ({ page }) => {
        await expect(page.locator("#calendar-inline-year")).toHaveScreenshot(
          "year-default.png",
        );
      });

      test("a month in the year view opens that month", async ({ page }) => {
        const section = page.locator("#calendar-inline-year");
        await section.locator("[aria-label='March 2026']").click();
        await expect(
          section.getByRole("heading", { level: 2, name: "March 2026" }),
        ).toBeVisible();
        await expect(section).toHaveScreenshot("year-opened-month.png");
      });

      test("decade", async ({ page }) => {
        await expect(page.locator("#calendar-inline-decade")).toHaveScreenshot(
          "decade-default.png",
        );
      });

      test("a year opened from the keyboard", async ({ page }) => {
        const section = page.locator("#calendar-inline-decade");
        await focusDay(section, "2024-01-01");
        await page.keyboard.press("Enter");
        await expect(section.locator("[data-date='2024-01-01']")).toBeFocused();
        await expect(section).toHaveScreenshot("decade-opened-year.png");
      });
    });
  });
}

test.describe("turbo mode requests", () => {
  test.beforeEach(({ page }) => visit(page, "?navigation=turbo"));

  test("loading", async ({ page }) => {
    const section = page.locator("#calendar-inline-month");
    let release;
    await page.route(monthRequest, async (route) => {
      await new Promise((resolve) => (release = resolve));
      await route.continue();
    });
    try {
      await navigation(section, "next").click();
      await expect(section.locator("turbo-frame")).toHaveAttribute(
        "aria-busy",
        "true",
      );
      await expect(section).toHaveScreenshot("month-loading.png");
    } finally {
      release?.();
    }
  });

  test("failed load keeps the current month", async ({ page }) => {
    const section = page.locator("#calendar-inline-month");
    await page.route(monthRequest, (route) =>
      route.fulfill({ status: 500, body: "" }),
    );
    await navigation(section, "next").click();
    await expect(section.locator("[role='status']")).toHaveText(
      "The calendar could not be loaded",
    );
    await expect(
      section.getByRole("heading", { level: 2, name: "September 2026" }),
    ).toBeVisible();
    await expect(section).toHaveScreenshot("month-failed.png");
  });
});

test.describe("native date field", () => {
  // WebKit shows today in an empty native date field.
  test.beforeEach(async ({ page }) => {
    await page.clock.setFixedTime(new Date("2026-09-10T12:00:00Z"));
    await visit(page);
  });

  test("default", async ({ page }) => {
    await expect(page.locator("#calendar-inline-native")).toHaveScreenshot(
      "native-default.png",
    );
  });
});

test.describe("calendar — forced colors", () => {
  test.beforeEach(({ page }) => visit(page));

  test.skip(
    ({ browserName }) => browserName !== "chromium",
    "Only Chromium emulates forced colors",
  );

  test("selected, focused, today, and unavailable days", async ({ page }) => {
    const section = page.locator("#calendar-inline-month");
    await page.emulateMedia({ forcedColors: "active" });
    await focusDay(section, "2026-09-15");
    await page.keyboard.press("ArrowRight");
    await expect(section).toHaveScreenshot("month-forced-colors.png");
  });
});

test.describe("narrow viewport", () => {
  test.use({ viewport: { width: 320, height: 640 } });
  test.beforeEach(({ page }) => visit(page));

  test("month at 320px", async ({ page }) => {
    await expect(page.locator("#calendar-inline-month")).toHaveScreenshot(
      "month-320.png",
    );
  });
});
