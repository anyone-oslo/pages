# Text formatting

## Basic formatting

**bold** and *italic* is written as:

```
*bold*
_italic_
```

Multiple level headlines

```
h1. Large headline

h2. Medium headline

h3. Small headline
```

Links

```
"Anyone":http://anyone.no/
```

Bullet points

```
* A list
* with several
* bullet points
```

Numbered lists

```
# Step 1
# Step 2
# Step 3
```

Block quotes

```
bq. This is a block quote
```

## Images

Images can be embedded with `[image:123]`, where 123 is the ID of the image. This embed code can also be obtained by clicking on an image. 

It is also possible to give the embedded image a class, depending on the template:

```
[image:123 class="small"]
```

## Rich text editor

Templates with `text_filter :document` (see [Templates](templates.md#rich-text-editor))
use the rich text editor instead of Textile. The text is stored as HTML
wrapped in `<notextile>`, so it renders through the same formatter as
Textile. Images and files are stored as `[image:123]` and `[attachment:123]`
codes.

Textile is converted when a block is opened in the editor, and stored as
HTML only when the block is edited. Legacy `[file:123]` codes, which point at
a page file rather than an attachment, become `[attachment:ID]` codes on
conversion.

Switching a template back to `:textile` keeps the pages rendering as before,
but the admin then shows the stored HTML in the Textile field.
