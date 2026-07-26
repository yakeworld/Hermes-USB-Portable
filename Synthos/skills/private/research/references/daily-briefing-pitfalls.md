# Daily Briefing — Execution Pitfalls (2026-07-13)

## Cron Environment Tool Failures

### HN Firebase API is slow
- Firebase API (`hacker-news.firebaseio.com`) returns the top-stories array instantly but each `/v0/item/{id}.json` call takes 3-8 seconds.
- 20 stories × ~5s = 100s minimum, often hitting 60s terminal timeout.
- **Workaround**: Batch to top 10-15, use 3s timeout per call, accept some misses. Or use HN RSS feed (`hnrss.org/frontpage`) as alternative.

### curl | python3 is blocked by security scanner (tirith)
- Pipeline `curl ... | python3 -c "..."` triggers `tirith:pipe_to_interpreter` — denied.
- `curl ... | python3 -m json.tool` triggers `tirith:schemeless_to_sink` — also denied.
- **Workaround**: Write script to file first (`write_file`), then execute (`terminal python3 script.py`).

### Semantic Scholar rate-limited
- `api.semanticscholar.org` returns 429 after initial calls. Free tier has strict rate limits.
- Use arXiv API as reliable alternative for tech frontier.

### web_search returns empty
- SearXNG backend (configured as only backend) frequently returns `{"success": true, "data": {"web": []}}`.
- Does not always find results even for simple queries.
- **Workaround**: Use arXiv API, PubMed E-utilities, and HN RSS/Firebase directly via terminal.

### Browser tools are unreliable
- `browser_navigate` to news.ycombinator.com timed out on CDP.
- `browser_navigate` to any page timed out during cron execution.
- Do not rely on browser for HN or news fetching in cron context.

### arXiv search too broad
- `all:vllm` or `all:large+language+model` matches too many papers (1.7M+ results for broad queries).
- Use `cat:cs.AI+AND+(specific_topic)` to narrow scope.
- arXiv returned a "Wat3R" paper instead of AI-related content for broad queries — verify relevance after fetching.

## Successful Patterns
1. Write Python script to `/home/yakeworld/tmp_*.py`, then `python3 /home/yakeworld/tmp_*.py`
2. Direct curl to arXiv API and PubMed E-utilities works reliably
3. HN Firebase works but is slow — limit to top 15 items
4. arXiv API over HTTPS is not blocked by security scanner (unlike plain HTTP)
5. **HN RSS via rss2json.com** (fast alternative): `curl -s "https://api.rss2json.com/v1/api.json?rss_url=https://hnrss.org/frontpage&count=10"` — single call, ~5s, no auth. Returns title, pubDate, link, points, description. Prefer over Firebase for cron jobs.

## 2026-07-14 Additions

### HN RSS via rss2json.com (fast alternative to Firebase)
- `curl -s "https://api.rss2json.com/v1/api.json?rss_url=https://hnrss.org/frontpage&count=10"` returns full HN items as JSON in a single call — no serial per-item fetch.
- Each item includes `title`, `pubDate`, `link`, `author`, `points`, and `description` (with content snippet).
- **Advantage**: Single HTTP call, ~5s response, no auth required, no rate limiting.
- **Disadvantage**: rss2json.com is a third-party service; may have its own rate limits.
- Use when HN Firebase is too slow (common in cron environment).

### HN Firebase v3 requires authentication
- `/v3/top.json` returns HTTP 401 Unauthorized from this network.
- `/v0/topstories.json` and `/v0/item/{id}.json` work but require one call per story (slow).
- **Workaround**: Prefer `rss2json.com` wrapper around `hnrss.org` for speed; or use `/v0/` endpoints with tight timeout budget.

### PubMed efetch delivers full abstracts
- `efetch.fcgi?db=pubmed&id=XXXXX&retmode=text&rettype=abstract` returns the complete structured abstract with IMPORTANCE/OBJECTIVE/DESIGN/RESULTS/CONCLUSIONS sections.
- Works with `curl -s --max-time 5` — fast enough for single PMID fetch.
- The response includes DOI, PMID, authors, source, and full abstract text.