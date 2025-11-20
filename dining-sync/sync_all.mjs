import { createClient } from "@supabase/supabase-js";
import { classifyItemsWithAI } from "./ai_filter.mjs";

// ============================================================================
// CONFIGURATION
// ============================================================================

// Read from environment (GitHub Actions secrets)
const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_ANON_KEY = process.env.SUPABASE_ANON_KEY;

if (!SUPABASE_URL || !SUPABASE_URL.startsWith("http")) {
  throw new Error(`SUPABASE_URL is missing or invalid: "${SUPABASE_URL || ""}"`);
}

if (!SUPABASE_ANON_KEY) {
  throw new Error("SUPABASE_ANON_KEY is missing. Set it in GitHub Secrets.");
}

const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

// === FD MEALPLANNER CONFIG ===
const FD_API_BASE =
  "https://apiservicelocatorstenantgettysburg.fdmealplanner.com/api/v1/data-locator-webapi/19/meals";
const IMAGE_BASE = "https://gettysburglive.culinarysuite.com";
const TENANT_ID = "19";
const TIME_OFFSET_MINUTES = "300"; // EST offset

// === SYNC WINDOW CONFIG ===
// Override with environment variables if needed
const START_DATE = process.env.START_DATE; // Format: YYYY-MM-DD
const DAYS_AHEAD = parseInt(process.env.DAYS_AHEAD || "7", 10); // Default: 7 days for weekly runs

// ============================================================================
// FILTERING RULES
// ============================================================================

// Minimal exclusion list for obviously non-food or system items
// The AI will handle the main filtering logic
const MINIMAL_EXCLUSIONS = new Set([
  // Add only obvious junk items here if needed in the future
]);

// ============================================================================
// MEAL CONFIGURATIONS
// ============================================================================

const MEAL_CONFIGS = [
  {
    name: "Servo Lunch",
    accountId: "4",
    locationId: "4",
    mealPeriodId: "4",
    mealPeriodLabel: "Lunch",
    locationName: "Servo",
  },
  {
    name: "Servo Dinner",
    accountId: "4",
    locationId: "4",
    mealPeriodId: "5",
    mealPeriodLabel: "Dinner",
    locationName: "Servo",
  },
  {
    name: "Bullet Lunch",
    accountId: "1",
    locationId: "1",
    mealPeriodId: "4",
    mealPeriodLabel: "Lunch",
    locationName: "Bullet Hole",
  },
  {
    name: "Bullet Dinner",
    accountId: "1",
    locationId: "1",
    mealPeriodId: "5",
    mealPeriodLabel: "Dinner",
    locationName: "Bullet Hole",
  },
];

// ============================================================================
// UTILITY FUNCTIONS
// ============================================================================

/**
 * Build full image URL from relative path with proper encoding
 */
function buildImageUrl(relativePath) {
  if (!relativePath) return null;
  if (relativePath.startsWith("http")) return relativePath;
  
  // Encode special characters but preserve slashes
  const encoded = relativePath
    .split("/")
    .map((segment) => encodeURIComponent(segment))
    .join("/");
  
  return `${IMAGE_BASE}${encoded}`;
}

/**
 * Extract and clean dietary tags
 */
function extractDietaryTags(recipe) {
  const parts = [];

  if (recipe.recipeProductDietaryName) {
    parts.push(recipe.recipeProductDietaryName);
  }
  if (recipe.dietaryIcon) {
    parts.push(recipe.dietaryIcon);
  }
  if (recipe.dietaryName) {
    parts.push(recipe.dietaryName);
  }

  const unique = [
    ...new Set(
      parts
        .join(",")
        .split(",")
        .map((s) => s.trim())
        .filter(Boolean)
    ),
  ];
  return unique.join(", ");
}

/**
 * Normalize item name for deduplication
 * - Removes extra whitespace
 * - Converts to lowercase
 * - Removes special characters variations
 */
function normalizeItemName(name) {
  return name
    .trim()
    .replace(/\s+/g, " ") // Multiple spaces → single space
    .replace(/[–—]/g, "-") // En/em dashes → hyphen
    .toLowerCase();
}

/**
 * Format JavaScript Date to FD API format (YYYY/MM/DD)
 */
function formatFDDate(d) {
  const year = d.getFullYear();
  const month = String(d.getMonth() + 1).padStart(2, "0");
  const day = String(d.getDate()).padStart(2, "0");
  return `${year}/${month}/${day}`;
}

/**
 * Format JavaScript Date to database format (YYYY-MM-DD)
 */
function formatDBDate(d) {
  const year = d.getFullYear();
  const month = String(d.getMonth() + 1).padStart(2, "0");
  const day = String(d.getDate()).padStart(2, "0");
  return `${year}-${month}-${day}`;
}

/**
 * Convert FD date string (YYYY/MM/DD) to database format (YYYY-MM-DD)
 */
function convertFDDateToDB(fdDate) {
  return fdDate.replace(/\//g, "-");
}

// ============================================================================
// DATE RANGE CALCULATION
// ============================================================================

/**
 * Calculate the date range for syncing
 */
function calculateDateRange() {
  let startDate;
  
  if (START_DATE) {
    // Parse START_DATE from YYYY-MM-DD format
    const [year, month, day] = START_DATE.split("-").map(Number);
    startDate = new Date(year, month - 1, day);
    console.log(`📅 Using START_DATE from environment: ${START_DATE}`);
  } else {
    startDate = new Date();
    console.log(`📅 Using today as start date: ${formatDBDate(startDate)}`);
  }

  const endDate = new Date(startDate);
  endDate.setDate(endDate.getDate() + DAYS_AHEAD - 1);

  console.log(`📅 Date range: ${formatDBDate(startDate)} → ${formatDBDate(endDate)} (${DAYS_AHEAD} days)`);

  return { startDate, endDate };
}

// ============================================================================
// FD API INTERACTION
// ============================================================================

/**
 * Fetch menu data from FD API for given date range
 */
async function fetchFDRange(config, startDate, endDate) {
  const monthId = String(startDate.getMonth() + 1);

  const params = new URLSearchParams({
    menuId: "0",
    accountId: config.accountId,
    locationId: config.locationId,
    mealPeriodId: config.mealPeriodId,
    tenantId: TENANT_ID,
    monthId,
    startDate: formatFDDate(startDate),
    endDate: formatFDDate(endDate),
    timeOffset: TIME_OFFSET_MINUTES,
  });

  const url = `${FD_API_BASE}?${params.toString()}`;

  console.log(`[FD] ${config.name}: Fetching from API...`);

  const res = await fetch(url, {
    headers: {
      "User-Agent": "Mozilla/5.0",
      Accept: "application/json",
    },
  });

  if (!res.ok) {
    throw new Error(
      `[FD] ${config.name}: API error ${res.status} ${res.statusText}`
    );
  }

  const json = await res.json();
  return json;
}

// ============================================================================
// DATA PROCESSING & FILTERING
// ============================================================================

/**
 * Build concept/station lookup map from conceptData array
 * 
 * @param {Array} conceptData - Array of concept objects from FD API
 * @returns {Map<number, string>} Map from conceptId to conceptName
 */
function buildConceptMap(conceptData) {
  const map = new Map();
  if (!conceptData || !Array.isArray(conceptData)) {
    return map;
  }
  
  for (const concept of conceptData) {
    if (concept.conceptId && concept.conceptName) {
      map.set(concept.conceptId, concept.conceptName);
    }
  }
  
  return map;
}

/**
 * Collect candidate menu items from FD data before AI filtering
 * Returns both rows for insertion and summary for AI classification
 * 
 * @param {Object} config - Meal configuration
 * @param {Array} results - FD API result array (multiple days)
 * @param {Map<number, string>} conceptMap - Map from conceptId to conceptName
 * @returns {Object} { rows: Array, summary: Map }
 */
function collectCandidates(config, results, conceptMap) {
  const rows = [];
  const itemStats = new Map(); // Track stats per item name for AI summary

  for (const dayData of results) {
    const served_on = convertFDDateToDB(dayData.strMenuForDate);
    const location = config.locationName;
    const meal_period = config.mealPeriodLabel;

    // Handle both possible field names for recipes array
    const allRecipes = dayData.allMenuRecipes || dayData.menuRecipiesData || [];

    // STEP 1: Filter OUT bar items (isFoodBar === "1")
    // This is the KEY filter - bar items are always available
    const nonBarItems = allRecipes.filter((r) => r.isFoodBar !== "1");

    // STEP 2: Filter to Entree category only (most reliable for daily specials)
    // We focus on entrees as they are the main specials
    const entrees = nonBarItems.filter((r) => {
      const category = (r.category || "").trim();
      return category === "Entree" || category === " Entree";
    });

    // STEP 3: Require valid image URL
    const withImages = entrees.filter((r) => !!r.recipeImagePath || !!r.recipeImage);

    // STEP 4: Apply minimal exclusions (only obvious junk)
    const filtered = withImages.filter((r) => {
      const name = (
        r.componentEnglishName ||
        r.englishAlternateName ||
        r.componentName ||
        ""
      ).trim();
      if (!name) return false;
      if (MINIMAL_EXCLUSIONS.has(name)) return false;
      return true;
    });

    console.log(
      `[SYNC] ${config.name} ${served_on}: ` +
        `${allRecipes.length} total → ` +
        `${nonBarItems.length} non-bar → ` +
        `${entrees.length} entrees → ` +
        `${withImages.length} with images → ` +
        `${filtered.length} candidates`
    );

    // STEP 5: Build rows and track item stats
    for (const r of filtered) {
      const itemName =
        r.englishAlternateName ||
        r.componentEnglishName ||
        r.componentName ||
        "Unknown";
      const imagePath = r.recipeImagePath || r.recipeImage || "";
      const hasImage = !!imagePath;

      // Get station name from conceptId
      const conceptId = r.conceptId;
      const stationName = conceptMap.get(conceptId) || "Unknown Station";

      // Create row for database
      const row = {
        served_on,
        location,
        meal_period,
        item_name: itemName.trim(),
        image_url: buildImageUrl(imagePath),
        dietary_tags: extractDietaryTags(r),
        station: stationName,
      };
      rows.push(row);

      // Track stats for AI summary
      if (!itemStats.has(itemName)) {
        itemStats.set(itemName, {
          name: itemName,
          dates: new Set(),
          locations: new Set(),
          meal_periods: new Set(),
          has_image: hasImage,
        });
      }
      const stats = itemStats.get(itemName);
      stats.dates.add(served_on);
      stats.locations.add(location);
      stats.meal_periods.add(meal_period);
    }
  }

  // Convert item stats to AI summary format
  const summaryItems = Array.from(itemStats.values()).map((stats) => ({
    name: stats.name,
    days_count: stats.dates.size,
    dates: Array.from(stats.dates).sort(),
    locations: Array.from(stats.locations),
    meal_periods: Array.from(stats.meal_periods),
    has_image: stats.has_image,
  }));

  console.log(
    `[SYNC] ${config.name}: Collected ${rows.length} candidate rows, ` +
      `${summaryItems.length} unique items`
  );

  return { rows, summaryItems };
}

/**
 * Sync one meal period for the given date range
 */
async function syncMealPeriod(config, startDate, endDate) {
  console.log(`\n${"=".repeat(70)}`);
  console.log(`🍽️  SYNCING: ${config.name}`);
  console.log(`${"=".repeat(70)}`);

  try {
    // STEP 1: Fetch data from FD API
    const json = await fetchFDRange(config, startDate, endDate);

    const results = json.result || [];
    console.log(`[FD] ${config.name}: Received ${results.length} day entries`);

    if (results.length === 0) {
      console.log(`[SYNC] ${config.name}: No data returned from FD API`);
      return { success: true, inserted: 0 };
    }

    // STEP 2: Build concept/station map from the first result's conceptData
    const conceptData = results[0]?.conceptData || [];
    const conceptMap = buildConceptMap(conceptData);
    console.log(
      `[SYNC] ${config.name}: Found ${conceptMap.size} stations: ` +
        `${Array.from(conceptMap.values()).join(", ")}`
    );

    // STEP 3: Collect candidate items (before AI filtering)
    const { rows: candidateRows, summaryItems } = collectCandidates(config, results, conceptMap);

    if (candidateRows.length === 0) {
      console.log(`[SYNC] ${config.name}: No candidate items found`);
      return { success: true, inserted: 0 };
    }

    // STEP 4: Call AI to classify items
    console.log(
      `[SYNC] ${config.name}: Calling AI to classify ${summaryItems.length} unique items...`
    );
    const aiDecisions = await classifyItemsWithAI({
      location: config.locationName,
      mealPeriod: config.mealPeriodLabel,
      items: summaryItems,
    });

    // STEP 5: Filter rows based on AI decisions
    const filteredRows = candidateRows.filter((row) => {
      const decision = aiDecisions.get(row.item_name);
      return decision?.keep === true;
    });

    const removedCount = candidateRows.length - filteredRows.length;
    console.log(
      `[SYNC] ${config.name}: AI filtered ${candidateRows.length} → ${filteredRows.length} rows ` +
        `(removed ${removedCount})`
    );

    if (filteredRows.length === 0) {
      console.log(`[SYNC] ${config.name}: No rows remain after AI filtering`);
      return { success: true, inserted: 0 };
    }

    // STEP 6: Deduplicate by (served_on, location, meal_period, item_name, station)
    const dedupMap = new Map();
    for (const row of filteredRows) {
      const key = `${row.served_on}|${row.location}|${row.meal_period}|${normalizeItemName(row.item_name)}|${row.station}`;
      if (!dedupMap.has(key)) {
        dedupMap.set(key, row);
      }
    }
    const dedupedRows = Array.from(dedupMap.values());

    const dupeCount = filteredRows.length - dedupedRows.length;
    if (dupeCount > 0) {
      console.log(`[SYNC] ${config.name}: Removed ${dupeCount} duplicate(s)`);
    }

    // STEP 7: Show summary by date and station
    const itemsByDate = {};
    for (const row of dedupedRows) {
      if (!itemsByDate[row.served_on]) {
        itemsByDate[row.served_on] = [];
      }
      itemsByDate[row.served_on].push(`${row.item_name} (${row.station})`);
    }

    console.log(`[SYNC] ${config.name}: Final menu summary:`);
    for (const [date, items] of Object.entries(itemsByDate).sort()) {
      console.log(`   ${date}: ${items.length} items - ${items.join(", ")}`);
    }

    // STEP 8: Insert into Supabase
    console.log(
      `[SYNC] ${config.name}: Inserting ${dedupedRows.length} rows into Supabase...`
    );

    const { data, error } = await supabase
      .from("dining_menu_items")
      .insert(dedupedRows)
      .select();

    if (error) {
      console.error(`[SYNC] ${config.name}: Supabase error:`, error.message);
      console.error(`   Details:`, error);
      return { success: false, error: error.message };
    }

    const insertedCount = data?.length ?? 0;
    console.log(`[SYNC] ${config.name}: ✅ Successfully inserted ${insertedCount} rows`);

    return { success: true, inserted: insertedCount };
  } catch (err) {
    console.error(`[SYNC] ${config.name}: ❌ Unexpected error:`, err.message);
    console.error(`   Stack:`, err.stack);
    return { success: false, error: err.message };
  }
}

// ============================================================================
// CLEANUP FUNCTIONS
// ============================================================================

/**
 * Delete ALL existing data in the table (complete fresh start)
 */
async function clearAllData() {
  console.log(`\n${"=".repeat(70)}`);
  console.log(`🗑️  CLEARING ALL EXISTING DATA`);
  console.log(`${"=".repeat(70)}`);
  console.log(`[SYNC] ⚠️  This will delete ALL menu items from the database`);

  try {
    // Delete all rows
    const { data, error } = await supabase
      .from("dining_menu_items")
      .delete()
      .neq("id", 0) // Delete everything (id != 0 means all rows)
      .select();

    if (error) {
      console.error("[SYNC] ❌ Error clearing data:", error.message);
      return { success: false, error: error.message };
    }

    const deletedCount = data?.length ?? 0;
    console.log(`[SYNC] ✅ Deleted ${deletedCount} existing rows (fresh start)`);

    return { success: true, deleted: deletedCount };
  } catch (err) {
    console.error("[SYNC] ❌ Unexpected error during cleanup:", err.message);
    return { success: false, error: err.message };
  }
}

// ============================================================================
// MAIN EXECUTION
// ============================================================================

async function main() {
  console.log("\n" + "=".repeat(70));
  console.log("🚀 GETTYSBURG DINING MENU SYNC - PRODUCTION VERSION");
  console.log("=".repeat(70));

  // Calculate date range
  const { startDate, endDate } = calculateDateRange();

  // Step 1: Clear ALL existing data for a fresh start
  console.log("\n🧹 Step 1: Clearing all existing menu data...");
  const clearResult = await clearAllData();
  if (!clearResult.success) {
    console.error("❌ Failed to clear existing data. Aborting.");
    process.exit(1);
  }

  // Step 2: Sync all meal periods
  console.log("\n📥 Step 2: Fetching and syncing meal data...");
  const results = [];
  for (const config of MEAL_CONFIGS) {
    const result = await syncMealPeriod(config, startDate, endDate);
    results.push({ name: config.name, ...result });
  }

  // Step 3: Print summary
  console.log("\n" + "=".repeat(70));
  console.log("📊 FINAL SYNC SUMMARY");
  console.log("=".repeat(70));

  let totalInserted = 0;
  let failures = 0;

  for (const result of results) {
    const status = result.success ? "✅" : "❌";
    const count = result.inserted ?? 0;
    totalInserted += count;
    if (!result.success) failures++;

    console.log(`${status} ${result.name}: ${count} rows inserted`);
    if (result.error) {
      console.log(`   Error: ${result.error}`);
    }
  }

  console.log("\n" + "=".repeat(70));
  console.log(`🎉 TOTAL: ${totalInserted} rows inserted into clean database`);
  if (failures > 0) {
    console.log(`⚠️  ${failures} meal period(s) had errors`);
  }
  console.log("=".repeat(70) + "\n");

  if (failures > 0) {
    process.exit(1);
  }
}

main();
