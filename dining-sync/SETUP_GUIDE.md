# Setup Guide: AI-Powered Dining Sync

This guide will help you set up and run the AI-powered dining menu sync system.

## Prerequisites

- Node.js 16+ installed
- Supabase project with `dining_menu_items` table
- Google AI Studio API key

## Step 1: Database Setup

Run this SQL in your Supabase SQL Editor:

```sql
-- Create table (if not exists)
CREATE TABLE IF NOT EXISTS dining_menu_items (
  id BIGSERIAL PRIMARY KEY,
  served_on DATE NOT NULL,
  location TEXT NOT NULL,
  meal_period TEXT NOT NULL,
  item_name TEXT NOT NULL,
  image_url TEXT,
  dietary_tags TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add unique constraint to prevent duplicates
ALTER TABLE dining_menu_items
ADD CONSTRAINT dining_menu_items_unique
UNIQUE (served_on, location, meal_period, item_name);

-- Optional: Add index for faster queries
CREATE INDEX IF NOT EXISTS idx_dining_menu_date 
ON dining_menu_items(served_on DESC);
```

## Step 2: Get Google AI Studio API Key

1. Visit [Google AI Studio](https://aistudio.google.com/app/apikey)
2. Sign in with your Google account
3. Click "Create API Key"
4. Copy the key (keep it secure!)

**Note**: The free tier is sufficient for this application (4 API calls per week).

## Step 3: Install Dependencies

```bash
cd dining-sync
npm install
```

## Step 4: Set Environment Variables

### Option A: Export in Terminal (for testing)

```bash
export SUPABASE_URL="https://xxxxx.supabase.co"
export SUPABASE_ANON_KEY="your-anon-key"
export GOOGLE_API_KEY="your-google-api-key"
```

### Option B: Create .env file (for local development)

Create a `.env` file in the `dining-sync` folder:

```bash
SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
GOOGLE_API_KEY=your-google-api-key-here
```

Then use with a tool like `dotenv`:

```bash
npm install --save-dev dotenv
node -r dotenv/config sync_all.mjs
```

### Option C: GitHub Actions (for production)

Set these as repository secrets:

1. Go to your repo → Settings → Secrets and variables → Actions
2. Add these secrets:
   - `SUPABASE_URL`
   - `SUPABASE_ANON_KEY`
   - `GOOGLE_API_KEY`

## Step 5: Test the AI Filter

Test the AI classification logic in isolation:

```bash
export GOOGLE_API_KEY="your-key"
npm test
```

This runs `test_ai_filter.mjs` with sample data and validates the results.

Expected output:

```
🧪 TESTING AI FILTER
✅ GOOGLE_API_KEY found

📋 Sample Items:
  • Cheesesteak (1 days)
  • Penne Pasta (7 days)
  • Shredded Lettuce (7 days)
  ...

🤖 Calling AI classifier...
[AI] 🤖 Calling Google AI Studio...
[AI] ✅ Parsed decisions for 8 / 8 items

📊 RESULTS
✅ Cheesesteak
   Decision: KEEP
   Reason: Daily sandwich special
❌ Penne Pasta
   Decision: HIDE
   Reason: Always available pasta bar staple
...

📊 SUMMARY: 4 kept, 4 hidden
```

## Step 6: Run Full Sync

Run the complete sync (fetches from FD, classifies with AI, inserts to DB):

```bash
export SUPABASE_URL="https://xxxxx.supabase.co"
export SUPABASE_ANON_KEY="your-anon-key"
export GOOGLE_API_KEY="your-google-api-key"

npm run sync
```

Or directly:

```bash
node sync_all.mjs
```

## Step 7: Verify Results

Check your Supabase database:

```sql
-- Count total items
SELECT COUNT(*) FROM dining_menu_items;

-- See items by location and date
SELECT 
  served_on, 
  location, 
  meal_period, 
  COUNT(*) as item_count
FROM dining_menu_items
GROUP BY served_on, location, meal_period
ORDER BY served_on, location, meal_period;

-- View specific items
SELECT * FROM dining_menu_items
WHERE served_on = CURRENT_DATE
ORDER BY location, meal_period, item_name;
```

## Customization

### Adjust Date Range

Sync a specific date range:

```bash
export START_DATE="2025-11-25"
export DAYS_AHEAD=14  # 2 weeks
npm run sync
```

### Modify AI Rules

Edit the prompt in `ai_filter.mjs` → `buildPrompt()` function:

```javascript
function buildPrompt(items, location, mealPeriod) {
  return `You are helping simplify a college dining app menu...
  
  DECISION RULES:
  1. [Your custom rule here]
  2. [Another custom rule]
  ...`;
}
```

### Add Manual Exclusions

Edit `sync_all.mjs` → `MINIMAL_EXCLUSIONS`:

```javascript
const MINIMAL_EXCLUSIONS = new Set([
  "System Test Item",
  "Do Not Display",
  // Add other obvious junk items
]);
```

## Troubleshooting

### Error: "GOOGLE_API_KEY not set"

The sync will continue with a fallback heuristic (frequency-based filtering).

**Fix**: Export the `GOOGLE_API_KEY` environment variable.

### Error: "No such file or directory: .env"

If using Option B above, make sure:
1. You created the `.env` file
2. You're running from the `dining-sync` directory
3. You installed `dotenv` package

### Error: "SUPABASE_URL is missing"

**Fix**: Export `SUPABASE_URL` and `SUPABASE_ANON_KEY` before running.

### Error: "There is no unique or exclusion constraint"

**Fix**: Run the unique constraint SQL from Step 1.

### AI returns unexpected results

1. Check the test script: `npm test`
2. Review AI decisions in the logs
3. Adjust the prompt in `ai_filter.mjs`
4. Consider upgrading to `gemini-1.5-pro` for better quality

## Production Deployment

### GitHub Actions Workflow

Create `.github/workflows/sync-dining.yml`:

```yaml
name: Sync Dining Menus

on:
  schedule:
    - cron: '0 2 * * 1'  # Every Monday at 2 AM UTC
  workflow_dispatch:  # Allow manual trigger

jobs:
  sync:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
      
      - name: Install dependencies
        run: |
          cd dining-sync
          npm install
      
      - name: Run sync
        env:
          SUPABASE_URL: ${{ secrets.SUPABASE_URL }}
          SUPABASE_ANON_KEY: ${{ secrets.SUPABASE_ANON_KEY }}
          GOOGLE_API_KEY: ${{ secrets.GOOGLE_API_KEY }}
        run: |
          cd dining-sync
          node sync_all.mjs
```

## Monitoring

### Log Prefixes

- `[FD]` - FD API fetch operations
- `[SYNC]` - Data processing and orchestration
- `[AI]` - AI classification calls

### Key Metrics to Monitor

1. **Items collected** vs **items inserted** (filtering ratio)
2. **AI success rate** (how often fallback is used)
3. **Sync duration** (should be < 2 minutes)
4. **Database row count** (should grow weekly)

### Success Criteria

A successful sync should show:

```
[FD] Servo Lunch: Received 7 day entries
[SYNC] Servo Lunch: Collected 45 candidate rows, 18 unique items
[AI] 🤖 Calling Google AI Studio for Servo Lunch with 18 items...
[AI] ✅ Parsed decisions for 18 / 18 items
[SYNC] Servo Lunch: AI filtered 45 → 23 rows
[SYNC] Servo Lunch: ✅ Successfully inserted 23 rows

🎉 TOTAL: 92 rows inserted into clean database
```

## Support

For issues or questions:
1. Check logs for `[AI]` warnings or errors
2. Run `npm test` to validate AI behavior
3. Review the README.md for detailed documentation
4. Check Supabase dashboard for data validation

## Next Steps

- Set up automated monitoring/alerts for sync failures
- Add Slack/email notifications on sync completion
- Create a dashboard to visualize menu trends
- Implement caching for frequently appearing items

