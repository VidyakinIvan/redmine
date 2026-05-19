module.exports = {
  "ignoreFiles": [
    "src/sass/vendor/**"
  ],
  "extends": [
    "stylelint-config-standard-scss",
    "stylelint-config-property-sort-order-smacss",
  ],
  "rules": {
    "alpha-value-notation": "number",
    "selector-id-pattern": null,
    "selector-class-pattern": null,
    "media-feature-name-no-vendor-prefix": null,
    "media-feature-name-no-unknown": null,
    "no-descending-specificity": null,
    "font-family-no-missing-generic-family-keyword": null,
    "at-rule-empty-line-before": null,
  }
};
