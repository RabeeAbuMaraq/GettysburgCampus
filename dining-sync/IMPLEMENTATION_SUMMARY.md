# AI Integration Implementation Summary

## What Was Changed

### 1. New Files Created

#### `ai_filter.mjs`
- Main AI classification module
- Integrates with Google AI Studio (Gemini 1.5 Flash)
- Sends item summaries, receives keep/hide decisions
- Robust error handling with fallback heuristic
- Uses `process.env.GOOGLE_API_KEY` (never hardcoded)

#### `test_ai_filter.mjs`
- Standalone test script for AI classification
- Tests with sample dining items
- Validates expected behavior
- Useful for debugging and development

#### Documentation Files
- `README.md` - Complete system documentation
- `SETUP_GUIDE.md` - Step-by-step setup instructions
- `IMPLEMENTATION_SUMMARY.md` - This file

### 2. Files Modified

#### `sync_all.mjs` - Major Refactor

**Removed:**
- Large hard-coded exclusion lists (`BULLET_ALWAYS_AVAILABLE`, `SERVO_ALWAYS_AVAILABLE`)
- `exclusionList` property from `MEAL_CONFIGS`
- Old `processMenuItems()` function with manual filtering

**Added:**
- Import for `classifyItemsWithAI` from `ai_filter.mjs`
- `MINIMAL_EXCLUSIONS` set (empty, for future use)
- New `collectCandidates()` function that:
  - Collects all candidate items across all days
  - Builds item summaries with stats (days_count, dates, locations, etc.)
  - Returns both rows and summary for AI classification

**Modified:**
- `syncMealPeriod()` now follows new flow:
  1. Fetch from FD API
  2. Collect candidates and build summaries
  3. Call AI classifier
  4. Filter rows based on AI decisions
  5. Deduplicate and insert to Supabase
- Updated all console logs to use prefixes: `[FD]`, `[SYNC]`, `[AI]`

#### `package.json`
- Changed `type` from `"commonjs"` to `"module"` for ES modules support
- Added `"sync"` script: `node sync_all.mjs`
- Changed `"test"` script to run: `node test_ai_filter.mjs`
- Updated version to `2.0.0`
- Added description and keywords

## How It Works Now

### Old Flow (Hard-Coded Filtering)
```
FD API → Filter by exclusion list → Require images → Insert to DB
```

### New Flow (AI-Powered Filtering)
```
FD API → Collect candidates → Build summaries → AI classification → Filter by AI decisions → Insert to DB
```

### AI Classification Process

1. **Summary Format Sent to AI:**
```json
[
  {
    "name": "Cheesesteak",
    "days_count": 1,
    "dates": ["2025-11-19"],
    "locations": ["Bullet Hole"],
    "meal_periods": ["Lunch"],
    "has_image": true
  }
]
```

2. **AI Returns Decisions:**
```json
{
  "items": [
    {
      "name": "Cheesesteak",
      "keep": true,
      "reason": "Daily sandwich special"
    }
  ]
}
```

3. **System Filters Rows:**
- Only rows with `keep: true` are inserted into Supabase
- All decisions are logged for transparency

## API Usage

### Calls Per Week
- **4 API calls** per weekly sync (one per meal period)
- Servo Lunch, Servo Dinner, Bullet Lunch, Bullet Dinner

### Cost
- **Free tier** is sufficient
- Gemini 1.5 Flash is extremely fast and cost-effective

### Fallback Behavior
If AI is unavailable:
- Uses frequency heuristic: hide items appearing 5+ days per week
- Logs warning but continues sync
- Never fails the entire sync

## Environment Variables Required

### Production (GitHub Actions)
Set these as repository secrets:
```
SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_ANON_KEY=your-anon-key
GOOGLE_API_KEY=your-google-api-key
```

### Local Development
Export these before running:
```bash
export SUPABASE_URL="https://xxxxx.supabase.co"
export SUPABASE_ANON_KEY="your-anon-key"
export GOOGLE_API_KEY="your-google-api-key"
```

## Testing

### Test AI Filter Alone
```bash
export GOOGLE_API_KEY="your-key"
npm test
```

### Run Full Sync
```bash
export SUPABASE_URL="https://xxxxx.supabase.co"
export SUPABASE_ANON_KEY="your-anon-key"
export GOOGLE_API_KEY="your-google-api-key"
npm run sync
```

## Database Requirements

The Supabase table needs a unique constraint:

```sql
ALTER TABLE dining_menu_items
ADD CONSTRAINT dining_menu_items_unique
UNIQUE (served_on, location, meal_period, item_name);
```

This prevents duplicate items from being inserted.

## What You Need to Do

### Immediate Actions

1. **Get Google AI Studio API Key**
   - Visit https://aistudio.google.com/app/apikey
   - Create a free API key
   - Store securely

2. **Add to GitHub Secrets**
   - Go to your repo → Settings → Secrets
   - Add secret: `GOOGLE_API_KEY` with your key

3. **Test Locally (Optional)**
   ```bash
   cd dining-sync
   export GOOGLE_API_KEY="your-key"
   npm test
   ```

4. **Run Full Sync Test (Optional)**
   ```bash
   export SUPABASE_URL="your-url"
   export SUPABASE_ANON_KEY="your-key"
   export GOOGLE_API_KEY="your-google-key"
   npm run sync
   ```

5. **Verify Database**
   - Check Supabase for new items
   - Verify only relevant specials are showing
   - Check that bar staples are filtered out

### Future Enhancements (Optional)

1. **Create GitHub Actions Workflow**
   - Use template from `SETUP_GUIDE.md`
   - Schedule weekly runs
   - Add Slack/email notifications

2. **Monitor AI Performance**
   - Review AI decisions in logs
   - Adjust prompt if needed
   - Track filtering accuracy

3. **Tune AI Prompt**
   - Edit `buildPrompt()` in `ai_filter.mjs`
   - Add location-specific rules
   - Adjust strictness (currently: "when in doubt, hide it")

## Benefits of AI Filtering

### Before (Hard-Coded Lists)
- ❌ Required manual maintenance of 200+ item exclusions
- ❌ Couldn't adapt to new items
- ❌ Hard to explain filtering logic
- ❌ Separate lists per location
- ❌ Missed edge cases

### After (AI Powered)
- ✅ Learns and adapts to new items automatically
- ✅ Understands context (frequency, naming patterns)
- ✅ Transparent decisions with reasons
- ✅ Single prompt applies to all locations
- ✅ Handles edge cases intelligently

## Monitoring & Maintenance

### Key Logs to Watch

**Success Pattern:**
```
[FD] Servo Lunch: Received 7 day entries
[SYNC] Servo Lunch: Collected 45 candidate rows, 18 unique items
[AI] 🤖 Calling Google AI Studio for Servo Lunch with 18 items...
[AI] ✅ Parsed decisions for 18 / 18 items
[AI] 📊 Summary: Keep 8, Hide 10
[SYNC] Servo Lunch: ✅ Successfully inserted 23 rows
```

**Warning Pattern (Fallback Used):**
```
[AI] ⚠️  GOOGLE_API_KEY not set. Using fallback heuristic.
[AI] 🔄 Using fallback heuristic for Servo Lunch
```

**Error Pattern:**
```
[AI] ❌ API error: 429 Too Many Requests
[AI] 🔄 Using fallback heuristic
```

### Adjusting the AI

If AI is too strict (hiding good items):
- Edit prompt in `ai_filter.mjs` → `buildPrompt()`
- Change "When in doubt, hide it" to "When in doubt, keep it"
- Add examples of items to keep

If AI is too lenient (keeping bar staples):
- Add more examples to "Hide" section
- Strengthen frequency rule
- Add specific patterns to hide

## File Structure

```
dining-sync/
├── sync_all.mjs              # Main orchestrator
├── ai_filter.mjs             # AI integration
├── test_ai_filter.mjs        # Test script
├── package.json              # Dependencies & scripts
├── README.md                 # Full documentation
├── SETUP_GUIDE.md           # Setup instructions
└── IMPLEMENTATION_SUMMARY.md # This file
```

## Backward Compatibility

The system maintains backward compatibility:
- If `GOOGLE_API_KEY` is not set, falls back to frequency heuristic
- Still clears and re-inserts all data (same as before)
- Same Supabase table structure
- Same date range configuration

## Next Steps

1. ✅ Get Google AI Studio API key
2. ✅ Add to GitHub Secrets
3. ✅ Test locally with `npm test`
4. ✅ Run full sync with `npm run sync`
5. ✅ Verify results in Supabase
6. Create GitHub Actions workflow (optional)
7. Set up monitoring/alerts (optional)

## Questions?

- Check `README.md` for detailed API documentation
- Check `SETUP_GUIDE.md` for step-by-step setup
- Review logs with `[AI]` prefix for AI-specific issues
- Run `npm test` to validate AI behavior

---

**Implementation Complete** ✅

The system is ready to use. Just add your `GOOGLE_API_KEY` and run!

