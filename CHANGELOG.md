# Changelog

## [3.20.0](https://github.com/anyone-oslo/pages/compare/pages_core/v3.19.0...pages_core/v3.20.0) (2026-11-03)


### Upgrading

* Requires Rails 8.1 and dynamic_image 3.4.0 (which brings vector2d 3.0).
* Account recovery and invite emails build links from the request host only when `config.hosts` is set, and otherwise from `config.action_mailer.default_url_options`. Sending raises if neither has a host. Links use https unless a protocol is configured.
* Account recovery links sent before upgrading stop working.
* Rate limits are stored in `PagesCore.config.rate_limit_store`, which defaults to an in-process memory store. To share counters between processes, set it to a shared cache store in an initializer.
* Attachments other than images, PDF, audio and video are now downloaded instead of displayed in the browser. After deploying, purge cached attachments (`cache/attachments` with the file cache handler, `/attachments/` in Varnish).
* Custom static cache handlers must implement `purge_record!` and `tag_permanently`, and accept `tags:` in `cache_page_permanently`.


### Features

* add a button to log out all sessions ([ec42828](https://github.com/anyone-oslo/pages/commit/ec428280d3a8386231dfd6c7c8665d0957b884d6))
* rate limit login, 2FA, account recovery and invite acceptance ([0696b5a](https://github.com/anyone-oslo/pages/commit/0696b5a5540935e412bd0c41074cf60b08e81e40))


### Bug Fixes

* block data URLs in safe_url and JS-escape host on error pages ([2dd3ffc](https://github.com/anyone-oslo/pages/commit/2dd3ffca0487e8c37722df8e288ad0641ec5d9d8))
* build account links from a trusted host, single-use recovery links ([a52b172](https://github.com/anyone-oslo/pages/commit/a52b172c74c5b6792c916bf96389a9c8c310b171))
* cache only canonical URLs ([19383bf](https://github.com/anyone-oslo/pages/commit/19383bfef17fc00fcd8675e78fc31001b0f7592f))
* check image size whenever the file changes ([57fc433](https://github.com/anyone-oslo/pages/commit/57fc4331a604b847825424d78cebcaa9d548d22b))
* confirm account changes with the current password or 2FA code ([128d1bc](https://github.com/anyone-oslo/pages/commit/128d1bcce0125fa18cb02d9296aeeeb38ba90a54))
* **deps:** require pg_search 2.4 ([#266](https://github.com/anyone-oslo/pages/issues/266)) ([76221e2](https://github.com/anyone-oslo/pages/commit/76221e28017f412b0fb5c6bb8c41343c579b5d21))
* expire invites after 14 days and use the invited email ([ae2be57](https://github.com/anyone-oslo/pages/commit/ae2be57d5a9df2b02338f541142b41b3389c714c))
* keep the pending two-factor login in the session ([d45332f](https://github.com/anyone-oslo/pages/commit/d45332f40b2893e2fba6e0342d79244490858ea3))
* limit formatting in embedded captions and attachment names ([8f31efd](https://github.com/anyone-oslo/pages/commit/8f31efd39f62abed824e2668b20a5fdcf81bacc2))
* limit pagination params, prevent parent cycles and ignore unknown image params ([92ca8a6](https://github.com/anyone-oslo/pages/commit/92ca8a6ad2a8a47148172d37dddbd9365b6efc79))
* only show published pages in every format ([f69175a](https://github.com/anyone-oslo/pages/commit/f69175a19569b82ab2f5f7cb32a4a8ddcf71631f))
* refuse login for deactivated users ([2383fd6](https://github.com/anyone-oslo/pages/commit/2383fd60e2aa7edf4f702a9c079c46cec4aeda83))
* remove cached copies of deleted or replaced files ([1074a13](https://github.com/anyone-oslo/pages/commit/1074a136f77eec26a47b128c2f1b707a6eca5035))
* require a role to upload and edit images and attachments ([ac53abc](https://github.com/anyone-oslo/pages/commit/ac53abc6d8b130c621b72843cb798d48086136c8))
* require authorization for user admin ([097ca77](https://github.com/anyone-oslo/pages/commit/097ca779242fd34b2c2f07059e470ffe659a4b68))
* send filtered params to Sentry ([ba69939](https://github.com/anyone-oslo/pages/commit/ba6993951937abeb0169d1d54be26a7f7d6be628))
* serve only images, PDF, audio and video attachments inline ([b6ea55f](https://github.com/anyone-oslo/pages/commit/b6ea55f7578c98654c0bdb17ccc4ad597c63e47d))
* show the same account recovery message for every email ([8b3b36b](https://github.com/anyone-oslo/pages/commit/8b3b36b9e8a666c36c1ed48e5ef78a797b7ba619))
* stop preview before rendering when not logged in ([cd52fcc](https://github.com/anyone-oslo/pages/commit/cd52fcc2962704e35d310515c9599c0a63c5f29a))
* use secure_compare for token checks ([37146ec](https://github.com/anyone-oslo/pages/commit/37146ecee618d13d7dc208034041c26d370edc59))

## [3.19.0](https://github.com/anyone-oslo/pages/compare/pages_core/v3.18.1...pages_core/v3.19.0) (2026-09-28)


### Features

* allow marking images as decorative ([2fdd16e](https://github.com/anyone-oslo/pages/commit/2fdd16eac5389f4713e2627ac57db6d6fa3a8999)), closes [#249](https://github.com/anyone-oslo/pages/issues/249)
* build frontend assets at release time instead of committing them ([dd6e812](https://github.com/anyone-oslo/pages/commit/dd6e812cc211fe5227e2bcb2e3ae0f811721bcda))
* require Ruby 3.4 ([46ccaf5](https://github.com/anyone-oslo/pages/commit/46ccaf5adb43e2ad7d7bace14a086ce97ca3cbdf))


### Bug Fixes

* correct repository URLs in package.json ([e06b6f3](https://github.com/anyone-oslo/pages/commit/e06b6f3cf8cca6cca5d3e2abf01a3fd72f2f0af2))
* correct repository URLs in package.json ([7f1a7e7](https://github.com/anyone-oslo/pages/commit/7f1a7e7df59ac48af08dc8e1474041d9db9e9aaa))
* Define DefaultPolicy#index? instead of #index ([133424e](https://github.com/anyone-oslo/pages/commit/133424e57dae0f74c053a996f2a79321312f3afb))
* keep checkbox labels out of the field warning colour ([e817035](https://github.com/anyone-oslo/pages/commit/e81703590af30d36181eb0296d223126bcb52027))
* ship a minified, production build of the admin bundle ([0db2aaa](https://github.com/anyone-oslo/pages/commit/0db2aaa67dcec13cac85dd9987f193691327320a))

## [3.18.1](https://github.com/anyone-oslo/pages/compare/pages_core/v3.18.0...pages_core/v3.18.1) (2026-09-02)


### Bug Fixes

* Fix image content types and backfill ([b9f3691](https://github.com/anyone-oslo/pages/commit/b9f369113b0ce4792e5f7b64d1194d7cedfe0e31))

## [3.18.0](https://github.com/anyone-oslo/pages/compare/pages_core/v3.17.1...pages_core/v3.18.0) (2026-09-02)


### Features

* Adopt dynamic_image picture rendering ([f568d61](https://github.com/anyone-oslo/pages/commit/f568d617402999b7fb2e0fb4a0f5f58429843a60))

## [3.17.1](https://github.com/anyone-oslo/pages/compare/pages_core/v3.17.0...pages_core/v3.17.1) (2026-08-29)


### Bug Fixes

* drop the dead name attribute from image exports ([ca6640c](https://github.com/anyone-oslo/pages/commit/ca6640c98e04d03a756a98ad61c60d330c90f2b5))
* require dis 2.2 and dynamic_image 3.0.9 ([3d43033](https://github.com/anyone-oslo/pages/commit/3d430336b8f87bee95e5125ad5915d3f9c550eb3))
* serve attachments with send_dis_data ([95f3fc5](https://github.com/anyone-oslo/pages/commit/95f3fc55b5abc02da3e81c4662bd40f09a3dc89e))
* serve attachments with send_dis_data ([f7043c9](https://github.com/anyone-oslo/pages/commit/f7043c9badd0b720984748c6ae3dc2c9108eb218))
* stream attachments and images when exporting ([9bf6ceb](https://github.com/anyone-oslo/pages/commit/9bf6ceb46c8153bd0ea5ae2ebdf1aa21896c2903))

## [3.17.0](https://github.com/anyone-oslo/pages/compare/pages_core/v3.16.9...pages_core/v3.17.0) (2026-08-20)


### Features

* **meta_tags:** add og:image size, type and alt ([#224](https://github.com/anyone-oslo/pages/issues/224)) ([c54e86d](https://github.com/anyone-oslo/pages/commit/c54e86d8897d2cbb5c0ca49ff527e1d84089d8eb)), closes [#223](https://github.com/anyone-oslo/pages/issues/223)


### Bug Fixes

* trust the committed lockfile in pnpm supply-chain checks ([6f7d6b1](https://github.com/anyone-oslo/pages/commit/6f7d6b10f812dbc5a04ebf468d349c9226d80b03))

## [3.16.9](https://github.com/anyone-oslo/pages/compare/pages_core/v3.16.8...pages_core/v3.16.9) (2026-06-15)


### Bug Fixes

* regenerate lockfile with allowBuilds config ([7b33bbf](https://github.com/anyone-oslo/pages/commit/7b33bbf51f0e5b1f143a6b2544eea36ff16b9d76))
* WCAG mandatory baseline for frontend generator ([27fa55d](https://github.com/anyone-oslo/pages/commit/27fa55d8d8be0c10646fd255122daf8a9f57d3c1))

## [3.16.8](https://github.com/anyone-oslo/pages/compare/pages_core/v3.16.7...pages_core/v3.16.8) (2026-05-13)


### Bug Fixes

* require TLD in email validation ([#167](https://github.com/anyone-oslo/pages/issues/167)) ([36c78bc](https://github.com/anyone-oslo/pages/commit/36c78bc6e811c72e188bf01611cf84970352df8e))
* **sentry:** exclude PagesCore::NotAuthorized from reports ([#169](https://github.com/anyone-oslo/pages/issues/169)) ([e53ee98](https://github.com/anyone-oslo/pages/commit/e53ee989ba76c49c32c86a70895f717f22e08ad8))

## [3.16.7](https://github.com/anyone-oslo/pages/compare/pages_core/v3.16.6...pages_core/v3.16.7) (2026-05-13)


### Bug Fixes

* **meta_tags:** force og:url encoding to UTF-8 ([#164](https://github.com/anyone-oslo/pages/issues/164)) ([e478662](https://github.com/anyone-oslo/pages/commit/e4786621dd8f3e40720d0d7cd79b0938a31941d5))
* **tree:** guard next_sibling and previous_sibling when self not in siblings ([#166](https://github.com/anyone-oslo/pages/issues/166)) ([55182d3](https://github.com/anyone-oslo/pages/commit/55182d3e2edce94bf56c13eb223f50d5a68e6157))

## [3.16.6](https://github.com/anyone-oslo/pages/compare/pages_core/v3.16.5...pages_core/v3.16.6) (2026-04-29)


### Bug Fixes

* **errors:** fall back to 404 for unknown status codes in show ([357bac8](https://github.com/anyone-oslo/pages/commit/357bac80fdb081f67b2b8a98e790c9f6119ae64e))


### Performance Improvements

* Fix N+1 queries in ArchiveFinder#years_with_count ([8cd045e](https://github.com/anyone-oslo/pages/commit/8cd045e6107fc8f19856e60a058589e2e0413ed2))
* Lazy-load heavy dependencies at call sites ([205b9aa](https://github.com/anyone-oslo/pages/commit/205b9aa9e12edf95a47414bf569064c0cc85b6d8))

## [3.16.5](https://github.com/anyone-oslo/pages/compare/pages_core/v3.16.4...pages_core/v3.16.5) (2026-02-23)


### Bug Fixes

* Include spec/support/fixtures in gem package ([133552f](https://github.com/anyone-oslo/pages/commit/133552f8f000493439c0759027fb62dd1000f1da))

## [3.16.4](https://github.com/anyone-oslo/pages/compare/pages_core/v3.16.3...pages_core/v3.16.4) (2026-02-22)


### Bug Fixes

* Relax overly restrictive dependencies ([41fbcf9](https://github.com/anyone-oslo/pages/commit/41fbcf908b0e6e217e205ab57d1f471de2485651))

## [3.16.3](https://github.com/anyone-oslo/pages/compare/pages_core/v3.16.2...pages_core/v3.16.3) (2026-02-21)


### Bug Fixes

* Fix TypeScript errors for React 19 ([0eb6eac](https://github.com/anyone-oslo/pages/commit/0eb6eac01dfd6c018f139c085bbcb58e7dafdb37))
* Update to React 19 ([f7cda04](https://github.com/anyone-oslo/pages/commit/f7cda049bcf9a2e8a9e656cb052e018edc6653e7))

## [3.16.2](https://github.com/anyone-oslo/pages/compare/pages_core/v3.16.1...pages_core/v3.16.2) (2026-02-17)


### Bug Fixes

* Include spec/factories in gem file list ([46a8839](https://github.com/anyone-oslo/pages/commit/46a8839ee2306e7278d7c999911bcd93fe5f7ca8))

## [3.16.1](https://github.com/anyone-oslo/pages/compare/pages_core/v3.16.0...pages_core/v3.16.1) (2026-02-17)


### Bug Fixes

* Update tombolo ([63619f4](https://github.com/anyone-oslo/pages/commit/63619f46e626612fe787005bd0e09376aa9e2ed5))

## [3.16.0](https://github.com/anyone-oslo/pages/compare/pages_core/v3.15.10...pages_core/v3.16.0) (2026-02-15)


### Features

* Add safe_url view helper ([72db398](https://github.com/anyone-oslo/pages/commit/72db3984f3dec3bb6a7889ee5b68d4c66afe4998))
* Replace react-rails with Tombolo ([e87582d](https://github.com/anyone-oslo/pages/commit/e87582d2fbd978025af932759f24e084ccf0546a))


### Bug Fixes

* Serialize nested Alba resources to hashes before JSON encoding ([d9b419e](https://github.com/anyone-oslo/pages/commit/d9b419e664001f4599017f782e9b982504de91d8))
* Tweak Rubocop line lengths ([842b42d](https://github.com/anyone-oslo/pages/commit/842b42d86fbd79ce1809f25b877038888ffede52))

## [3.15.10](https://github.com/anyone-oslo/pages/compare/pages_core-v3.15.9...pages_core/v3.15.10) (2026-02-05)


### Bug Fixes

* Add missing not_found method to AttachmentsController ([bdd22eb](https://github.com/anyone-oslo/pages/commit/bdd22eb4b637a4198f15bf6a99e4279af598e4db))
* pin connection_pool to 2.x until react-rails supports 3.0 ([3d2f3d1](https://github.com/anyone-oslo/pages/commit/3d2f3d1cf21801f9aae9e426bc597ef35b0bd8ae))

## [3.15.9](https://github.com/anyone-oslo/pages/compare/pages_core-v3.15.8...pages_core-v3.15.9) (2026-01-22)


### Bug Fixes

* Sync VERSION file and configure release-please to update it ([0b0c4a4](https://github.com/anyone-oslo/pages/commit/0b0c4a4cb5399ec0bbf021445b966c79195a6826))

## [3.15.8](https://github.com/anyone-oslo/pages/compare/pages_core-v3.15.7...pages_core-v3.15.8) (2026-01-22)


### Bug Fixes

* Correct repository URL in package.json ([515252e](https://github.com/anyone-oslo/pages/commit/515252e209c5b33ebcd239536099cded6cb69be1))

## [3.15.7](https://github.com/anyone-oslo/pages/compare/pages_core-v3.15.6...pages_core-v3.15.7) (2026-01-22)


### Bug Fixes

* Add libvips to publish-rubygems job ([5e3405f](https://github.com/anyone-oslo/pages/commit/5e3405f58ec0452edd45949a0aa97a9d763bb60d))

## [3.15.6](https://github.com/anyone-oslo/pages/compare/pages_core-v3.15.5...pages_core-v3.15.6) (2026-01-22)


### Bug Fixes

* Use custom error class in OtpSecret#verify_secret ([fcbb67f](https://github.com/anyone-oslo/pages/commit/fcbb67ff0becfcb8d453f88f6ff6ec559910a89d))
