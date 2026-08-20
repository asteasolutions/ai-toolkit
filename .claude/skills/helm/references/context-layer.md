# The context layer

Domain knowledge docs (glossaries, decision records, or whatever the repo already uses) are optional. Discover them if present; do not invent a layout or create them from scratch.

## Read (orientation)

If such docs exist for the area you are touching, load the relevant ones. Do not trust them blindly:

1. Prefer git history — if the code changed since the doc was last touched, treat the doc as **suspect**.
2. When suspect, spot-check against the code in the task's area and flag mismatches in the orientation digest.
3. The Intent gate is the backstop — the developer sees the digest.

If none exist, proceed without them.

## Write (Reconcile)

Every Reconcile has a doc-impact line. Default `none`.

Only when a durable domain change landed **and** domain knowledge docs already exist: update those docs to match. Do not create new domain-doc trees or prescribe filenames.
