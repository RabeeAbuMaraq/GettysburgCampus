# Station/Concept Tracking Feature

## Overview

The dining sync now captures **which station or concept** each menu item comes from (e.g., "Abe's Faves", "Higher Bred", "Kazue", "Pi", "Root", "Soup of the Day").

## Stations by Location

### Bullet Hole Stations (6 stations)
- **Abe's Faves** - Daily specials and featured items
- **Higher Bred** - Sandwiches and wraps  
- **Pi** - Pizza station
- **Kazue** - Asian-inspired dishes
- **Root** - Salads and plant-based options
- **Soup of the Day** - Daily soups

### Servo Stations (9 stations)
- **Entree** - Main entrees
- **Saute** - Sautéed dishes
- **Chefs Table** - Chef's specialty items
- **Du Jour** - Daily features (soups, salads)
- **Smart Eats** - Health-focused options
- **Grill on Lincoln** - Grilled items (burgers, chicken)
- **Hot Cereal / Rice Corner** - Grains and cereals
- **The Bake Shop** - Baked goods and desserts
- **Servo Self Service** - Self-service items

**Note**: Each location has its own unique set of stations. The system automatically captures the correct stations for each location from the FD API.

## Database Schema

### New Column

```sql
ALTER TABLE public.dining_menu_items 
ADD COLUMN station text;
```

### Updated Unique Constraint

```sql
ALTER TABLE public.dining_menu_items
ADD CONSTRAINT dining_menu_items_unique
UNIQUE (served_on, location, meal_period, item_name, station);
```

This allows the same item to appear in multiple stations on the same day (e.g., "Chicken Breast" might appear in both "Abe's Faves" and "Kazue" with different preparations).

### Index for Performance

```sql
CREATE INDEX idx_dining_menu_station 
ON public.dining_menu_items(station);
```

## How It Works

### 1. FD API Response Structure

The FD API returns a `conceptData` array with station information:

```json
{
  "conceptData": [
    {
      "conceptId": 2,
      "conceptName": "Abe's Faves",
      "documentPath": "/Uploads/..._Abes_Favs.png"
    },
    {
      "conceptId": 11,
      "conceptName": "Higher Bred",
      "documentPath": "/Uploads/..._Higher_Bred.png"
    }
  ]
}
```

Each recipe/item has a `rowId` field that links to the concept's `rowId` to identify the station.

### 2. Processing Flow

1. **Build Concept Map**: Extract rowId → conceptName mapping from `conceptData`
2. **Link Items**: Match each recipe's `rowId` to concept's `rowId` to get station name
3. **Store Station**: Include station name in database row

### 3. Code Changes

**New Function**: `buildConceptMap(conceptData)`
- Creates a Map from rowId to conceptName
- Called once per API response

**Updated Function**: `collectCandidates(config, results, conceptMap)`
- Now accepts `conceptMap` parameter
- Extracts `rowId` from each recipe
- Looks up station name from map using rowId
- Adds `station` field to each row

**Updated Function**: `syncMealPeriod(config, startDate, endDate)`
- Builds concept map after fetching from API
- Passes map to `collectCandidates`
- Logs station names for debugging

## Usage Examples

### Query Items by Station

```sql
-- Get all items from Abe's Faves for today
SELECT item_name, meal_period 
FROM dining_menu_items
WHERE served_on = CURRENT_DATE 
  AND station = 'Abe''s Faves'
ORDER BY meal_period, item_name;
```

### Group Items by Station

```sql
-- Count items per station this week
SELECT station, COUNT(*) as item_count
FROM dining_menu_items
WHERE served_on >= CURRENT_DATE 
  AND served_on < CURRENT_DATE + INTERVAL '7 days'
GROUP BY station
ORDER BY item_count DESC;
```

### Show Full Menu with Stations

```sql
-- Today's full menu organized by station
SELECT 
  meal_period,
  station,
  item_name,
  dietary_tags
FROM dining_menu_items
WHERE served_on = CURRENT_DATE 
  AND location = 'Bullet Hole'
ORDER BY meal_period, station, item_name;
```

## App Integration Ideas

### 1. Station Filtering

Allow students to filter by their favorite stations:
```swift
// Filter to show only Abe's Faves and Kazue
let favoriteStations = ["Abe's Faves", "Kazue"]
items.filter { favoriteStations.contains($0.station) }
```

### 2. Station Badges

Show station name as a badge or tag:
```
Cheesesteak
[Abe's Faves] 🍔
```

### 3. Group by Station

Organize menu with section headers:
```
=== Abe's Faves ===
• Cheesesteak
• Pulled Pork Sandwich

=== Kazue ===
• Bibimbap Chicken
• Thai Red Curry

=== Pi ===
• Margherita Pizza
```

### 4. Station Icons

Use the icon paths from conceptData:
```json
{
  "documentPath": "/Uploads/Others_d394e9f5-bf8a-437e-bf4d-0f7ae2122bdf_Abes Favs.png"
}
```

Fetch and display station logos in the app.

### 5. Personalized Recommendations

Track which stations a student orders from most and highlight those items.

## Logging

The sync now logs station information:

```
[SYNC] Bullet Lunch: Found 6 stations: Abe's Faves, Higher Bred, Kazue, Pi, Root, Soup of the Day
[SYNC] Bullet Lunch: Final menu summary:
   2025-11-20: 8 items - Cheesesteak (Abe's Faves), Bibimbap Chicken (Kazue), Pepperoni Pizza (Pi), ...
```

## Benefits

1. **Better Organization**: Group items by station for clearer menu presentation
2. **User Preferences**: Allow students to filter/favorite specific stations
3. **Analytics**: Track which stations are most popular
4. **Context**: Show where each item is served ("Higher Bred sandwich station")
5. **Flexibility**: Same item name can appear in different stations with different preparations

## Backward Compatibility

- If `rowId` is missing from a recipe, station defaults to `"Unknown Station"`
- If `conceptData` array is empty, the sync still works (all items marked as "Unknown Station")
- If rowId doesn't match any concept, defaults to "Unknown Station"
- Existing code without station support can ignore the field

## Testing

After running the sync, verify stations are captured:

```sql
-- Check that stations are populated
SELECT DISTINCT station 
FROM dining_menu_items 
ORDER BY station;

-- Should return:
-- Abe's Faves
-- Higher Bred
-- Kazue
-- Pi
-- Root
-- Soup of the Day
```

## Future Enhancements

1. **Station-Specific AI Rules**: Adjust filtering rules per station (e.g., keep more items from "Abe's Faves")
2. **Station Hours**: Track which stations are open for which meals
3. **Station Descriptions**: Add description field with station details
4. **Station Images**: Store and serve station icon URLs
5. **Multi-Station Items**: Track if an item appears in multiple stations

---

**Implemented**: November 2025  
**Version**: 2.1.0

