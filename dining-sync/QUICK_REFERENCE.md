# Quick Reference - Dining Sync with AI

## 🚀 Quick Start

```bash
# 1. Set environment variables
export SUPABASE_URL="https://xxxxx.supabase.co"
export SUPABASE_ANON_KEY="your-anon-key"
export GOOGLE_API_KEY="your-google-ai-key"

# 2. Install dependencies
cd dining-sync
npm install

# 3. Test AI filter
npm test

# 4. Run full sync
npm run sync
```

## 📋 Commands

| Command | Description |
|---------|-------------|
| `npm install` | Install dependencies |
| `npm test` | Test AI classification with sample data |
| `npm run sync` | Run full sync (fetch, classify, insert) |
| `node sync_all.mjs` | Same as `npm run sync` |
| `node test_ai_filter.mjs` | Same as `npm test` |

## 🔑 Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `SUPABASE_URL` | ✅ Yes | Your Supabase project URL |
| `SUPABASE_ANON_KEY` | ✅ Yes | Supabase anonymous key |
| `GOOGLE_API_KEY` | ⚠️ Recommended | Google AI Studio API key |
| `START_DATE` | ❌ No | Start date (YYYY-MM-DD), defaults to today |
| `DAYS_AHEAD` | ❌ No | Number of days to sync, defaults to 7 |

## 🔗 Important Links

- **Google AI Studio**: https://aistudio.google.com/app/apikey
- **Supabase Dashboard**: https://supabase.com/dashboard

## 📂 Files

| File | Purpose |
|------|---------|
| `sync_all.mjs` | Main sync orchestrator |
| `ai_filter.mjs` | AI classification logic |
| `test_ai_filter.mjs` | Test script |
| `package.json` | Dependencies and scripts |
| `README.md` | Full documentation |
| `SETUP_GUIDE.md` | Step-by-step setup |
| `IMPLEMENTATION_SUMMARY.md` | What changed and why |

## 🧪 Testing

### Test AI Only (No Database)
```bash
export GOOGLE_API_KEY="your-key"
npm test
```

### Test Without AI Key (Fallback)
```bash
unset GOOGLE_API_KEY
npm test
```

### Test Full Sync (Dry Run)
```bash
# Set all env vars, then:
npm run sync
```

## 📊 Expected Output

### Successful Sync
```
🚀 GETTYSBURG DINING MENU SYNC
🗑️  CLEARING ALL EXISTING DATA
[SYNC] ✅ Deleted 84 existing rows

🍽️  SYNCING: Servo Lunch
[FD] Servo Lunch: Received 7 day entries
[SYNC] Servo Lunch: Collected 45 rows, 18 unique items
[AI] 🤖 Calling Google AI Studio...
[AI] ✅ Parsed decisions for 18 / 18 items
[AI] 📊 Summary: Keep 8, Hide 10
[SYNC] Servo Lunch: ✅ Successfully inserted 23 rows

... (Servo Dinner, Bullet Lunch, Bullet Dinner) ...

📊 FINAL SYNC SUMMARY
✅ Servo Lunch: 23 rows inserted
✅ Servo Dinner: 28 rows inserted
✅ Bullet Lunch: 19 rows inserted
✅ Bullet Dinner: 22 rows inserted

🎉 TOTAL: 92 rows inserted
```

### With Fallback Heuristic
```
[AI] ⚠️  GOOGLE_API_KEY not set. Using fallback heuristic.
[AI] 🔄 Using fallback heuristic for Servo Lunch
[AI] 📊 Fallback: Keep 8 / 18 items
```

## 🔍 Log Prefixes

| Prefix | Meaning |
|--------|---------|
| `[FD]` | FD MealPlanner API operations |
| `[SYNC]` | Data processing and orchestration |
| `[AI]` | AI classification calls |

## 🐛 Troubleshooting

| Issue | Solution |
|-------|----------|
| "GOOGLE_API_KEY not set" | Export the key: `export GOOGLE_API_KEY="your-key"` |
| "SUPABASE_URL is missing" | Export Supabase credentials |
| "No unique constraint" | Run the SQL from SETUP_GUIDE.md |
| AI returns wrong results | Edit prompt in `ai_filter.mjs` |
| Sync takes too long | Normal for first run (fetching week of data) |

## 📈 Monitoring

### Check Database
```sql
-- Count total items
SELECT COUNT(*) FROM dining_menu_items;

-- Items by date and station
SELECT served_on, location, meal_period, station, COUNT(*) 
FROM dining_menu_items
GROUP BY served_on, location, meal_period, station
ORDER BY served_on DESC, location, meal_period, station;

-- Today's menu with stations
SELECT item_name, station, meal_period, location
FROM dining_menu_items
WHERE served_on = CURRENT_DATE
ORDER BY location, meal_period, station, item_name;

-- Count items by station
SELECT station, COUNT(*) as item_count
FROM dining_menu_items
WHERE served_on >= CURRENT_DATE
GROUP BY station
ORDER BY item_count DESC;
```

### Verify AI Quality
```bash
# Run test and check accuracy
npm test

# Look for this output:
# 📈 Accuracy: 8/8 (100%)
```

## ⚙️ Configuration

### Adjust Date Range
```bash
export START_DATE="2025-11-25"
export DAYS_AHEAD=14  # 2 weeks
npm run sync
```

### Adjust AI Strictness
Edit `ai_filter.mjs` → `buildPrompt()`:
- Line 44: Change "When in doubt, hide it" to "When in doubt, keep it"

### Use Better AI Model
Edit `ai_filter.mjs` → Line 22:
- Change `gemini-2.5-flash` to `gemini-2.5-pro`

## 🔐 Security

- **Never commit API keys** to git
- Store keys in environment variables or GitHub Secrets
- Use `.env` file for local development (add to `.gitignore`)

## 📞 Support

1. Check `README.md` for detailed docs
2. Check `SETUP_GUIDE.md` for setup help
3. Run `npm test` to validate AI
4. Check logs for `[AI]` errors
5. Verify Supabase connection

## 🎯 Key Metrics

| Metric | Typical Value |
|--------|---------------|
| API calls per week | 4 |
| Items collected | 40-60 per meal period |
| Items kept | 20-30 per meal period |
| Filtering ratio | ~40-50% kept |
| Sync duration | < 2 minutes |

## 📚 Further Reading

- **Full Docs**: `README.md`
- **Setup Guide**: `SETUP_GUIDE.md`
- **What Changed**: `IMPLEMENTATION_SUMMARY.md`

---

**Ready to sync?** → `npm run sync` 🚀

