---
name: chengdu-flower-xhs-draft
description: Create Chengdu flower-shop Xiaohongshu/XHS posts from bouquet photos, including light image optimization, local-search copywriting, 20-character-ish emoji titles ending with 成都花店, visible hashtags, draft-box saving, and draft verification. Use when the user provides flower/bouquet images and asks for 小红书文案, 成都花店获客, 图片优化, 标题, 话题, or saving to 小红书草稿箱.
---

# Chengdu Flower XHS Draft

## Core Workflow

1. Inspect the bouquet image:
   - Identify color palette, flower style, recipient, gift scene, and whether the photo works as a 3:4 first image.
   - Prefer real texture over heavy filters. Do not make flowers look fake.
2. Optimize the image:
   - On macOS/Linux, use `scripts/optimize_xhs_image.sh <image> <out_dir>` when available.
   - On Windows PowerShell, use `scripts/optimize_xhs_image.ps1 -InputImage <image> -OutputDir <out_dir>`.
   - Main output: 1080x1440 JPG for Xiaohongshu first image.
   - Upload fallback: 720x960 JPG if browser upload is unstable.
3. Write the title:
   - Read `references/title-rules.md`.
   - Default rule: make the title as close as possible to Xiaohongshu's 20-character limit, include one emoji, and end with `成都花店`.
   - Use user-like hooks, not merchant directory labels.
4. Write the body:
   - First line: Chengdu/local need or gift-scene hook.
   - Middle: concrete bouquet details, who it is for, and when to send it.
   - Conversion line: ask for budget, recipient, district/area, delivery time, and disliked colors.
   - Include visible hashtags in the body instead of relying on topic binding.
5. Save as a draft only:
   - Use `opencli xiaohongshu publish ... --draft true --site-session persistent`.
   - Never publish unless the user explicitly asks to publish.
6. Verify:
   - Run `opencli xiaohongshu drafts --type image -f yaml`.
   - If `text_preview`/`draft-open` is empty, inspect IndexedDB `content.draftStore.desc`; newer creator drafts often store body text there.

## Research

When the user asks to base copy on current Chengdu users,同行爆款,全国爆款, or platform trends, use Xiaohongshu search first. Search examples:

```bash
opencli xiaohongshu search "成都花店 粉色花束 送女友" -f yaml
opencli xiaohongshu search "生日花束 女朋友" -f yaml
opencli xiaohongshu search "花束 送女友" -f yaml
```

Extract title patterns and user angles, then adapt them to the provided bouquet. Do not copy competitor wording verbatim.

## Draft Command Shape

```bash
CONTENT=$'正文...'
OPENCLI_BROWSER_COMMAND_TIMEOUT=180 opencli xiaohongshu publish "$CONTENT" \
  --title "标题💗成都花店" \
  --images "/absolute/path/to/optimized.jpg" \
  --draft true \
  --site-session persistent \
  --window foreground \
  --trace retain-on-failure \
  -f yaml
```

If upload fails or times out, retry with the 720x960 image and omit `--topics`; keep hashtags in the body.

## References

- Read `references/title-rules.md` before writing titles.
- Read `references/body-template.md` before writing the body.
- Read `references/draft-verification.md` when saving or checking drafts.
