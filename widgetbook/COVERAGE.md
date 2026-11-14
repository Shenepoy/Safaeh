# Public interface coverage

The catalog registers 74 named stories. This table accounts for every source
module exported by `lib/safaeh.dart`; helpers are exercised through their
owning component or an existing behavioral test. Rendering coverage is not a
claim that every combination of settings or every interaction is tested.

| Public module(s) | Story or behavioral coverage |
| --- | --- |
| `option_tile` | Controls → Option tile: default, long mixed text, labeled/disabled rows |
| `anchored_dropdown`, `anchored_popout` | Controls → Dropdown, Anchored popout; local navigator regression |
| `month_calendar`, `swatch_picker`, `cycle_button` | Controls → Calendar (fixed November 2026), Swatch picker, Cycle button |
| `meta_chip`, `content_panel`, `kpi_card` | Display → Meta chip, Content panel, KPI card; editable content/states |
| `glyph_avatar`, `bordered_list_chrome`, `section_header` | Display → Glyph avatar, Bordered list, Section header |
| `user_text`, `ltr_text`, `rtl` | Display → User text: mixed direction; root user-text tests |
| `accent_surfaces`, `material_chrome`, `floating_surface` | Display → Accent surfaces, Material chrome, Floating surfaces; Environment appearance setting |
| `inline_banner`, `empty_state` | Feedback → Inline banner info/error, Empty state |
| `async_body`, `error_body` | Feedback → Async body: data/loading/empty/error |
| `status_body`, `semantic_status` | Feedback → Status body with status knob; root status tests |
| `feedback` | Feedback → Feedback: local toast, action, dismissal; overlay cleanup integration test |
| `adaptive_sheet`, `sheet_handle_drag` | Sheets → Adaptive sheet, Sheet padding; root sheet/drag tests |
| `confirm`, `timed_confirm` | Sheets → Confirm default/destructive, Timed confirm |
| `dialog`, `info_sheet`, `action_sheet` | Sheets → Dialog, Information, Actions |
| `text_input`, `option_picker`, `tile_picker` | Sheets → Text input validation, Card picker, Tile picker search/empty/multiple |
| `sheet_template`, `sheet_template_style`, `sheet_data_loader`, `sheet_action_button` | Sheets → Sheet template, Sheet loading, Sheet action; theme/local slots, cached/read/retry states, action states and auxiliary controls; root template tests |
| `sheet_shell` | Sheets → Sheet shell, Sheet padding |
| `sidenav`, `floating_nav` | Navigation → Sidenav rail/drawer/overlay, Floating nav |
| `page_index`, `morphing_app_bar` | Navigation → Page index rail/overlay, App bar morphing |
| `content_band`, `content_aside`, `content_aligned` | Layout → Content band, End aside, Aligned chrome, Aligned page |
| `bottom_nav` | Layout → Keyboard and navigation; simulated keyboard inset; root bottom-nav tests |
| `display_cutout_layout`, `cutout_aware_fab_location` | Layout → Cutout avoidance; enable Environment → Simulated cutout; root cutout-layout tests |
| `device_cutout_scope` | Root display-cutout tests; native discovery intentionally not invoked by the web simulation |
| `camera_sheet`, `qr_scanner` | Camera → Camera sheet mock feed, QR overlay/permission message; root camera/QR tests |
| `onboarding`, `auth_flow` | Onboarding → Flow and Auth, all six designs; auth mode/busy/error knobs; root accessibility test |
| `debug_menu`, `l10n_editor` | Developer tools → Debug menu body in local sheet, Translation editor in memory |
| `theme` | All previews: theme, floating appearance, navigator scope; modal environment integration test |

The catalog's integration tests also check live knobs, live modal content,
theme/locale/platform/text-scale/reduced-motion propagation, resizing an open
sheet from 390 to 840 px, reset, feedback cleanup on navigation, and selected
Arabic stories at 2× text scale. They use bounded frames for perpetual loaders.

Settings tests exercise actual switches, dropdowns, sliders, and text editing,
including caret preservation and empty text. They verify each platform, surface
style, locale, and viewport; combined safe-area/keyboard/cutout settings; and
a bookmarked reload with Unicode and punctuation in knob values. They also
protect visible field labels and editor synchronization after URL changes.
