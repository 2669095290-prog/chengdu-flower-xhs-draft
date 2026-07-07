# Draft Verification

## Save Draft

Prefer:

```bash
CONTENT=$'正文...'
OPENCLI_BROWSER_COMMAND_TIMEOUT=180 opencli xiaohongshu publish "$CONTENT" \
  --title "标题💗成都花店" \
  --images "/absolute/path/to/image.jpg" \
  --draft true \
  --site-session persistent \
  --window foreground \
  --trace retain-on-failure \
  -f yaml
```

Use `--window foreground` for the first attempt when login or UI state may matter. Use background for listing drafts.

## List Drafts

```bash
OPENCLI_BROWSER_COMMAND_TIMEOUT=120 opencli xiaohongshu drafts \
  --type image \
  --site-session persistent \
  --window background \
  -f yaml
```

The list may show `text_preview: ''` even when the body exists.

## Verify Body In IndexedDB

When `draft-open` or the draft list shows empty content, open the creator page and read `draftStore.desc`:

```bash
opencli browser xhsverify open 'https://creator.xiaohongshu.com/publish/publish?from=menu_left&target=image'

JS=$'(async () => {
  const db = await new Promise((resolve, reject) => {
    const req = indexedDB.open("draft-database-v1");
    req.onsuccess = () => resolve(req.result);
    req.onerror = () => reject(req.error || new Error("open db failed"));
  });
  const tx = db.transaction("image-draft", "readonly");
  const store = tx.objectStore("image-draft");
  const rows = await new Promise((resolve, reject) => {
    const req = store.getAll();
    req.onsuccess = () => resolve(req.result || []);
    req.onerror = () => reject(req.error || new Error("read rows failed"));
  });
  db.close();
  const title = "PASTE_TITLE_HERE";
  const row = rows.find(r => (r?.content?.draftStore?.title || "") === title);
  if (!row) return {found:false};
  const ds = row.content.draftStore || {};
  return {found:true,title:ds.title,images:Array.isArray(ds.imgList)?ds.imgList.length:0,desc:(ds.desc || "").slice(0,700)};
})()'

opencli browser xhsverify eval "$JS"
opencli browser xhsverify close
```

Report the draft ID from `opencli xiaohongshu drafts`, image count, title, and whether `draftStore.desc` was found.
