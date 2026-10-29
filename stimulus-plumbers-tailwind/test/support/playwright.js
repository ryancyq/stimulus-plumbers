import { expect } from "@playwright/test";

/** Resolves once every finite animation and transition under `locator` has finished and its box holds for a frame. */
export const settled = (locator) =>
  locator.evaluate(async (element) => {
    await Promise.allSettled(
      element
        .getAnimations({ subtree: true })
        .filter(
          (animation) => animation.effect?.getTiming().iterations !== Infinity,
        )
        .map((animation) => animation.finished),
    );
    const box = () => JSON.stringify(element.getBoundingClientRect());
    let previous = null;
    for (let frame = 0; frame < 60; frame++) {
      await new Promise((resolve) => requestAnimationFrame(resolve));
      const current = box();
      if (current === previous) return;
      previous = current;
    }
    throw new Error("settled: the element kept moving for 60 frames");
  });

const unionOf = async (section, panel) => {
  const s = await section.boundingBox();
  const p = await panel.boundingBox();
  if (!s || !p)
    throw new Error(
      "screenshotWithPanel: the section or panel is not rendered",
    );
  const x = Math.min(s.x, p.x);
  const y = Math.min(s.y, p.y);
  return {
    x,
    y,
    width: Math.max(s.x + s.width, p.x + p.width) - x,
    height: Math.max(s.y + s.height, p.y + p.height) - y,
  };
};

const nextFrame = (page) =>
  page.evaluate(() => new Promise((resolve) => requestAnimationFrame(resolve)));

// Measures the section and panel until their union holds for a frame.
const stableUnionOf = async (page, section, panel, frames = 60) => {
  let previous = null;
  for (let frame = 0; frame < frames; frame++) {
    await nextFrame(page);
    const current = await unionOf(section, panel);
    if (previous && JSON.stringify(previous) === JSON.stringify(current)) {
      return current;
    }
    previous = current;
  }
  throw new Error(
    `screenshotWithPanel: the panel kept moving for ${frames} frames`,
  );
};

// A viewport corner outside the clip, else (0, 0): a full-width section's left padding.
const pointerRest = async (page, clip) => {
  const width = await page.evaluate(() => window.innerWidth);
  const height = await page.evaluate(() => window.innerHeight);
  const corners = [
    { x: width - 1, y: height - 1 },
    { x: 0, y: height - 1 },
    { x: width - 1, y: 0 },
    { x: 0, y: 0 },
  ];
  return (
    corners.find(
      ({ x, y }) =>
        x < clip.x ||
        x >= clip.x + clip.width ||
        y < clip.y ||
        y >= clip.y + clip.height,
    ) ?? { x: 0, y: 0 }
  );
};

/** Screenshots `section` together with its open popover panel. */
export async function screenshotWithPanel(
  page,
  section,
  filename,
  { panel = section.locator(":popover-open") } = {},
) {
  await expect(panel).toBeVisible();
  // The entrance transition offsets the panel until its transform is back to identity.
  await expect(panel).toHaveCSS(
    "transform",
    /^(none|matrix\(1, 0, 0, 1, 0, 0\))$/,
  );
  await settled(panel);
  let clip = await unionOf(section, panel);
  // Scrolls an off-screen pair into view before capturing.
  const viewportHeight = await page.evaluate(() => window.innerHeight);
  if (clip.y < 0 || clip.y + clip.height > viewportHeight) {
    await page.evaluate((top) => window.scrollBy(0, top), clip.y);
    clip = await stableUnionOf(page, section, panel);
    // Parks the pointer outside the clip, or on its padding.
    const rest = await pointerRest(page, clip);
    await page.mouse.move(rest.x, rest.y);
  }
  await expect(page).toHaveScreenshot(filename, { clip });
}
