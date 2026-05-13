import { Controller } from '@hotwired/stimulus';
import { attachFlipper } from '../plumbers';

export default class extends Controller {
  static targets = ['anchor', 'reference'];
  static values = {
    placement: { type: String, default: 'bottom' },
    alignment: { type: String, default: 'start' },
    role: { type: String, default: 'tooltip' },
  };

  connect() {
    if (!this.hasReferenceTarget) {
      console.error(
        'FlipperController requires a reference target. Add data-flipper-target="reference" to your element.'
      );
      return;
    }

    if (!this.hasAnchorTarget) {
      console.error('FlipperController requires an anchor target. Add data-flipper-target="anchor" to your element.');
      return;
    }

    attachFlipper(this, {
      element: this.referenceTarget,
      anchor: this.anchorTarget,
      placement: this.placementValue,
      alignment: this.alignmentValue,
      ariaRole: this.roleValue,
    });
  }
}
