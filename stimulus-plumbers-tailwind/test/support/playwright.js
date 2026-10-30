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
