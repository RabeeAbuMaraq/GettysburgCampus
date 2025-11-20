# Dining Menu Sync with AI Filtering

This system syncs dining menu data from FD MealPlanner to Supabase with intelligent AI-powered filtering using Google AI Studio (Gemini).

## Overview

The sync process:
1. Fetches menu data from FD MealPlanner for Gettysburg (Servo and Bullet Hole)
2. Extracts entree items with images
3. Sends item summaries to Google AI Studio for classification
4. AI decides which items are daily specials vs. always-available bar staples
5. Inserts only the filtered items into Supabase

## Environment Variables

### Required

```bash
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
GOOGLE_API_KEY=your-google-ai-studio-api-key
```

### Optional

```bash
START_DATE=2025-11-19        # Default: today
DAYS_AHEAD=7                 # Default: 7 days
```

## How It Works

### 1. Data Collection (`sync_all.mjs`)

For each meal period (Servo Lunch, Servo Dinner, Bullet Lunch, Bullet Dinner):
- Fetches FD API data for the date range
- Filters to entrees (non-bar items) with images
- Builds a summary of unique items with stats

### 2. AI Classification (`ai_filter.mjs`)

Sends item summaries to Google AI Studio with this format:

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

AI returns decisions:

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

### 3. AI Decision Rules

The AI follows these rules:

1. **Hide bar staples**: Base ingredients, salad components, toppings, sauces, sides, or bar staples
   - Examples: lettuce, cheese, dressing, rice, pasta, fries, generic proteins

2. **Hide frequent items**: Items appearing every day (days_count >= 6) that look generic

3. **Keep named dishes**: Named dishes or obvious daily specials
   - Examples: "Cheesesteak", "Bibimbap Chicken", "Jumbo Wings", "Red Pepper Soup"

4. **When in doubt, hide it**: Lean toward minimal menus focused on true specials

### 4. Fallback Behavior

If the AI is unavailable or fails:
- Uses simple heuristic: hide items appearing 5+ days per week
- Logs warning but continues sync
- Never hard-fails the sync due to AI issues

## Usage

### Local Development

```bash
cd dining-sync
export SUPABASE_URL="https://your-project.supabase.co"
export SUPABASE_ANON_KEY="your-anon-key"
export GOOGLE_API_KEY="your-google-api-key"

node sync_all.mjs
```

### GitHub Actions

Set these secrets in your repository:
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `GOOGLE_API_KEY`

The workflow will run weekly, calling the AI 4 times per run (one per meal period).

## API Usage

### Google AI Studio

- **Endpoint**: `gemini-2.5-flash` via REST API
- **Calls per run**: 4 (Servo Lunch, Servo Dinner, Bullet Lunch, Bullet Dinner)
- **Weekly usage**: ~4 calls
- **Free tier**: Sufficient for this usage

### Rate Limiting

The system minimizes API usage:
- Only calls AI once per meal period per run
- Sends compact summaries (not raw FD JSON)
- Short-circuits for 0 or 1 items (no AI call needed)

## Database Schema

The sync inserts into `dining_menu_items` table:

```sql
CREATE TABLE dining_menu_items (
  id BIGSERIAL PRIMARY KEY,
  served_on DATE NOT NULL,
  location TEXT NOT NULL,
  meal_period TEXT NOT NULL,
  item_name TEXT NOT NULL,
  image_url TEXT,
  dietary_tags TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Recommended unique constraint
ALTER TABLE dining_menu_items
ADD CONSTRAINT dining_menu_items_unique
UNIQUE (served_on, location, meal_period, item_name);
```

## File Structure

```
dining-sync/
├── sync_all.mjs      # Main orchestrator (FD fetch, AI filter, DB insert)
├── ai_filter.mjs     # Google AI Studio integration
├── package.json      # Dependencies (@supabase/supabase-js)
└── README.md         # This file
```

## Logging

The system uses prefixed logs for clarity:

- `[FD]` - FD API interactions
- `[SYNC]` - Sync orchestration and data processing
- `[AI]` - AI classification calls and results

Example output:

```
[FD] Servo Lunch: Fetching from API...
[FD] Servo Lunch: Received 7 day entries
[SYNC] Servo Lunch: Collected 45 candidate rows, 18 unique items
[AI] 🤖 Calling Google AI Studio for Servo Lunch with 18 items...
[AI] ✅ Parsed decisions for 18 / 18 items
[AI] 📊 Summary: Keep 8, Hide 10
[SYNC] Servo Lunch: AI filtered 45 → 23 rows (removed 22)
[SYNC] Servo Lunch: ✅ Successfully inserted 23 rows
```

## Troubleshooting

### AI Key Missing

If `GOOGLE_API_KEY` is not set:
```
[AI] ⚠️  GOOGLE_API_KEY not set. Using fallback heuristic.
```

The sync will continue using frequency-based filtering.

### AI Parse Error

If AI returns invalid JSON:
```
[AI] ❌ Failed to parse JSON response
[AI] 🔄 Using fallback heuristic
```

The sync will continue using fallback logic.

### Supabase Error

If database insert fails, the error is logged and the sync reports failure for that meal period.

## Maintenance

### Adjusting AI Rules

Edit the prompt in `ai_filter.mjs` → `buildPrompt()` function to modify classification rules.

### Manual Exclusions

Add obvious junk items to `MINIMAL_EXCLUSIONS` in `sync_all.mjs` if needed. Keep this list minimal - let the AI handle most filtering.

### AI Model

Currently uses `gemini-2.5-flash` for speed and cost. Can upgrade to `gemini-2.5-pro` for better quality by changing `GEMINI_ENDPOINT` in `ai_filter.mjs`.

