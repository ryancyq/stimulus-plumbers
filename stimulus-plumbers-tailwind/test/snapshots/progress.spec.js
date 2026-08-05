import { test, expect } from "@playwright/test";

test.beforeEach(async ({ page }) => {
  await page.goto("/components/display/progress");
  await page.waitForSelector("h1");
});

test.describe("progress", () => {
  test("bar", async ({ page }) => {
    await expect(page.locator("#progress-bar")).toHaveScreenshot("bar.png");
  });

  test("bar indeterminate", async ({ page }) => {
    await expect(page.locator("#progress-bar-indeterminate")).toHaveScreenshot(
      "bar-indeterminate.png",
    );
  });

  test("segmented", async ({ page }) => {
    await expect(page.locator("#progress-segmented")).toHaveScreenshot(
      "segmented.png",
    );
  });

  test("segmented ramp", async ({ page }) => {
    await expect(page.locator("#progress-segmented-ramp")).toHaveScreenshot(
      "segmented-ramp.png",
    );
  });

  test("segmented indeterminate 3 segments", async ({ page }) => {
    await expect(
      page.locator("#progress-segmented-indeterminate-3"),
    ).toHaveScreenshot("segmented-indeterminate-3.png");
  });

  test("segmented indeterminate", async ({ page }) => {
    await expect(
      page.locator("#progress-segmented-indeterminate"),
    ).toHaveScreenshot("segmented-indeterminate.png");
  });

  test("segmented indeterminate 10 segments", async ({ page }) => {
    await expect(
      page.locator("#progress-segmented-indeterminate-10"),
    ).toHaveScreenshot("segmented-indeterminate-10.png");
  });

  // The relay's per-slot timing is animation, which screenshots freeze — assert the live
  // computed values instead. Duration scales with count so per-slot glide speed matches the
  // bar (1.5s); each slot's delay staggers 1/count later, driving one chunk left-to-right.
  for (const { id, count } of [
    { id: "progress-segmented-indeterminate-3", count: 3 },
    { id: "progress-segmented-indeterminate", count: 5 },
    { id: "progress-segmented-indeterminate-10", count: 10 },
  ]) {
    test(`segmented indeterminate relay timing scales across ${count} segments`, async ({
      page,
    }) => {
      const slots = await page
        .locator(`#${id} [data-progress-target="fill"]`)
        .evaluateAll((els) =>
          els.map((el) => {
            const s = getComputedStyle(el);
            return {
              name: s.animationName,
              duration: parseFloat(s.animationDuration),
              delay: parseFloat(s.animationDelay),
              easing: s.animationTimingFunction,
            };
          }),
        );

      expect(slots).toHaveLength(count);
      const perSlot = 1.5 / count; // bar slide-duration split across the segments
      slots.forEach((slot, i) => {
        const last = i === count - 1;
        // Only the last slot parks the chunk to fade it out; the rest glide clear.
        expect(slot.name).toBe(
          last ? "sp-progress-relay-end" : "sp-progress-relay",
        );
        expect(slot.duration).toBeCloseTo(perSlot / 0.2, 3);
        expect(slot.delay).toBeCloseTo(i * perSlot, 3); // each slot takes its turn 1/count later
        // Constant speed through the middle; only the ends ramp in/out.
        const expectedEasing =
          i === 0 ? "ease-in" : last ? "ease-out" : "linear";
        expect(slot.easing).toBe(expectedEasing);
      });
    });
  }

  test("ring large", async ({ page }) => {
    await expect(page.locator("#progress-ring-lg")).toHaveScreenshot(
      "ring-lg.png",
    );
  });

  test("ring", async ({ page }) => {
    await expect(page.locator("#progress-ring")).toHaveScreenshot("ring.png");
  });

  test("ring indeterminate", async ({ page }) => {
    await expect(page.locator("#progress-ring-indeterminate")).toHaveScreenshot(
      "ring-indeterminate.png",
    );
  });

  test("meter", async ({ page }) => {
    await expect(page.locator("#progress-meter")).toHaveScreenshot("meter.png");
  });

  test("bar percent readout", async ({ page }) => {
    await expect(page.locator("#progress-bar-percent")).toHaveScreenshot(
      "percent.png",
    );
  });

  test("bar value max readout", async ({ page }) => {
    await expect(page.locator("#progress-bar-value-max")).toHaveScreenshot(
      "value-max.png",
    );
  });

  // The readout pill must stay legible where the fill edge is nowhere near it.
  test("bar percent readout at a low value", async ({ page }) => {
    await expect(page.locator("#progress-bar-percent-low")).toHaveScreenshot(
      "percent-low.png",
    );
  });

  test("bar percent readout at full", async ({ page }) => {
    await expect(page.locator("#progress-bar-percent-full")).toHaveScreenshot(
      "percent-full.png",
    );
  });
});
