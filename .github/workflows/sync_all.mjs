import { createClient } from "@supabase/supabase-js";

// ============================================================================
// CONFIGURATION
// ============================================================================

// === SUPABASE CONFIG ===
const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_ANON_KEY = process.env.SUPABASE_ANON_KEY;

if (!SUPABASE_URL || !SUPABASE_ANON_KEY) {
  throw new Error("Missing SUPABASE_URL or SUPABASE_ANON_KEY env vars");
}
const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

// === FD MEALPLANNER CONFIG ===
const FD_API_BASE =
  "https://apiservicelocatorstenantgettysburg.fdmealplanner.com/api/v1/data-locator-webapi/19/meals";
const IMAGE_BASE = "https://gettysburglive.culinarysuite.com";
const TENANT_ID = "19";
const TIME_OFFSET_MINUTES = "300"; // EST offset

// ============================================================================
// FILTERING RULES
// ============================================================================

// === Bullet Hole: Always-available items to EXCLUDE ===
const BULLET_ALWAYS_AVAILABLE = new Set([
  // Pasta varieties (always available at pasta bar)
  "Penne Pasta",
  "Rigatoni Pasta",
  "Rotini Pasta",
  "Ziti Pasta",
  "Campanelle Pasta",
  "Shells Pasta",
  "Spaghetti Pasta",
  "Seasoned Farfalle Bowtie Pasta",
  "Cheese Tortellini",
  "Gluten Free Pasta",

  // Pasta sauces
  "Alfredo Sauce",
  "Marinara",
  "Pizza Sauce",
  "White Pizza Sauce",

  // Bar proteins (NOT specials - these are always available)
  "Halal Gyro Cone", // Bar item - NOT the daily special "Gyro"
  "Athenian Precooked Gyros Slices", // Bar item
  "Chicken Breast",
  "Crispy Chicken Breast",
  "Diced Chicken Breast",
  "Italian Breaded Chicken Breast",
  "Italian Diced Chicken",
  "Buffalo Chicken",

  // Burger/sandwich bases
  "Beef Patty",
  "Black Bean Burger",
  "Vegan Chik'n Nuggets",
  "Chikn Nuggets",

  // Sides (always available)
  "French Fries",
  "Mac and Cheese",
  "White Rice",
  "Jasmine Rice",
  "Refried Beans",

  // Pizza bar
  "Pizza Dough",
  "Cauliflower Crust",

  // Deli meats (always available)
  "Hickory Smoked Turkey Breast",
  "Ham, Sliced",
  "Deli Roast Beef",
  "Pepperoni",
  "Pepperoni1",
  "Salami",
  "Sandwich Pepperoni",

  // Salad bar proteins
  "Sesame Tamari Tempeh",
  "Salmon",
  "Falafel",
  "Hard Boiled Eggs",

  // Breads and buns
  "Brioche Bun",
  "Turano Brioche Bun Vegan",
  "Philly Sub Roll",
  "Oven Fired Flatbread",
  "Everything Bagel",
  "Plain Bagel - BH",
  "Udis Plain Bagel",
  "Gluten Free Bread",
  "Spinach Tortilla",
  "Wheat Tortilla",

  // All cheeses (bar items)
  "Cheddar Cheese",
  "Sliced Cheddar Cheese",
  "Great Lakes Sliced Cheddar Cheese 6/24oz",
  "Pepper Jack Cheese",
  "Sliced Provolone Cheese",
  "Sliced Swiss Cheese",
  "Sliced American Cheese",
  "American Cheese",
  "Provolone Cheese",
  "Swiss Cheese",
  "Vegan Cheddar Cheese",
  "Monterey Jack Cheddar Shredded Cheese",
  "Feta Cheese",
  "Athenos Feta Cheese",
  "Fresh Ciliegini Mozzarella",
  "Shaved Parmesan",

  // All sauces and condiments
  "BBQ Sauce",
  "Cannonball BBQ Sauce",
  "Buffalo Sauce",
  "Nut-Free Basil Pesto Sauce",
  "Balsamic Vinaigrette",
  "Ranch Dressing",
  "Southwest Ranch",
  "Creamy Caesar Dressing",
  "Golden Italian Dressing",
  "Poppyseed Dressing",
  "Hot Honey",
  "Tzatziki",
  "Hummus",
  "Creamy Sriracha",
  "Serrano Chili Sauce",

  // All vegetables/salad components
  "BABY ARUGULA",
  "Baby Spinach",
  "Romaine Lettuce",
  "Shredded Lettuce",
  "Cherry Tomatoes",
  "Sliced Tomato",
  "Cucumber",
  "Shredded Carrots",
  "Red Onions",
  "Pickled Onion",
  "Green Bell Pepper",
  "Banana Pepper",
  "Pickled Jalapenos",
  "Sliced Black Olives",
  "Mixed Olives",
  "Pickled Sweet Peppers",
  "Mushrooms",
  "Basil",
  "Chickpea",
  "Edamame",
  "Quinoa",
  "Roasted Beets",
  "Sweet Yellow Corn",
  "Mandarin Orange Segments",
  "Crushed Pineapple",
  "Broccoli Florets",
  "Diced Sweet Potato",

  // Other bar items
  "Sliced Dill Pickles",
  "Bacon Bits",
  "Balsamic Glaze",
  "Garlic Infused Olive Oil",
  "Extra Virgin Olive Oil",
  "Balsamic Vinegar",
  "Tri-Color Tortilla Strips",
  "Herbed Croutons",
  "Dried Cranberries",
]);

// === Servo: Always-available grill items to EXCLUDE ===
const SERVO_ALWAYS_AVAILABLE = new Set([
  // Grill burgers/sandwiches (always available)
  "Grilled Hamburger",
  "Grilled Cheese",
  "Vegan Burger",
  "Beyond Burger",

  // Grilled chicken (always available in all seasonings)
  "Grilled Fresh Halal Chicken Breast",
  "Grilled Montreal Seasoned Chicken Breast",
  "Grilled Old Bay Chicken Breast",
  "Grilled Cajun Chicken Breast",
  "Grilled Mojito Lime Chicken Breast",
  "Grilled Rotisserie Seasoned Chicken Breast",
  "Grilled Tex-Mex Chicken Breast",
  "Grilled Honey BBQ Chicken Breast",
  "Grilled Poultry Seasoned Chicken Breast",
  "Grilled Just Plain Good Seasoned Chicken Breast",
  "Grilled Lime Pepper Chicken Breast",
  "Grilled Mediterranea n Chicken Breast",
  "Grilled Chipotle Cinnamon Chicken Breast",
  "Grilled Citrus and Herb Chicken Breast",

  // Pasta bar items
  "Penne Pasta",
  "Rigatoni Pasta",
  "Rotini Pasta",
  "Ziti Pasta",
  "Campanelle Pasta",
  "Shells Pasta",
  "Spaghetti Pasta",
  "Gemelli Pasta",
  "Cheese Tortellini",
  "Gluten Free Pasta",

  // Always-available sides
  "Jasmine Rice",
  "French Fries",
  "Bun",
  "Seasoned Loops",
  "Chicken Nuggets",

  // Bar items
  "Crispy Chicken Breast",
  "Vegan Meat Strips",
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
    exclusionList: SERVO_ALWAYS_AVAILABLE,
  },
  {
    name: "Servo Dinner",
    accountId: "4",
    locationId: "4",
    mealPeriodId: "5",
    mealPeriodLabel: "Dinner",
    exclusionList: SERVO_ALWAYS_AVAILABLE,
  },
  {
    name: "Bullet Lunch",
    accountId: "1",
    locationId: "1",
    mealPeriodId: "4",
    mealPeriodLabel: "Lunch",
    exclusionList: BULLET_ALWAYS_AVAILABLE,
  },
  {
    name: "Bullet Dinner",
    accountId: "1",
    locationId: "1",
    mealPeriodId: "5",
    mealPeriodLabel: "Dinner",
    exclusionList: BULLET_ALWAYS_AVAILABLE,
  },
];

// ============================================================================
// UTILITY FUNCTIONS
// ============================================================================

/**
 * Build full image URL from relative path
 */
function buildImageUrl(relativePath) {
  if (!relativePath) return null;
  if (relativePath.startsWith("http")) return relativePath;
  return `${IMAGE_BASE}${relativePath}`;
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
 * Extract clean location name from account name
 */
function extractLocation(accountName) {
  if (!accountName) return "Unknown";
  const parts = accountName.split("-");
  return (parts[1] || parts[0]).trim();
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
 * Generate unique key for deduplication
 */
function generateRowKey(row) {
  return `${row.served_on}|${row.location}|${row.meal_period}|${row.item_name}`;
}

/**
 * Deduplicate rows based on date/location/meal/item_name
 */
function deduplicateRows(rows) {
  const seen = new Map();

  for (const row of rows) {
    const key = generateRowKey(row);
    if (!seen.has(key)) {
      seen.set(key, row);
    }
  }

  return Array.from(seen.values());
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

  console.log(`[${config.name}] 🔍 Fetching from FD API...`);

  const res = await fetch(url, {
    headers: {
      "User-Agent": "Mozilla/5.0",
      Accept: "application/json",
    },
  });

  if (!res.ok) {
    throw new Error(
      `[${config.name}] FD API error: ${res.status} ${res.statusText}`
    );
  }

  const json = await res.json();
  return json;
}

// ============================================================================
// DATA PROCESSING & FILTERING
// ============================================================================

/**
 * Process and filter menu items according to our rules
 */
function processMenuItems(config, dayData) {
  const served_on = dayData.strMenuForDate;
  const accountName = dayData.accountName;
  const location = extractLocation(accountName);
  const meal_period = config.mealPeriodLabel;

  const allRecipes = dayData.allMenuRecipes || [];

  // STEP 1: Filter to Entrees only
  const entrees = allRecipes.filter((r) => r.category === "Entree");

  // STEP 2: Apply exclusion list
  let filtered = entrees;
  if (config.exclusionList) {
    filtered = entrees.filter((r) => {
      const name = (r.englishAlternateName || r.componentName || "").trim();
      if (!name) return false;

      // Exclude always-available items
      if (config.exclusionList.has(name)) {
        return false;
      }

      return true;
    });
  }

  // STEP 3: Require valid image URL
  const withImages = filtered.filter((r) => !!r.recipeImage);

  // Log filtering stats
  console.log(
    `[${config.name}] 📊 ${served_on}: ` +
      `${allRecipes.length} total → ${entrees.length} entrees → ` +
      `${filtered.length} filtered → ${withImages.length} with images`
  );

  // STEP 4: Map to our database schema
  const rows = withImages.map((r) => ({
    served_on,
    location,
    meal_period,
    item_name: r.englishAlternateName || r.componentName,
    image_url: buildImageUrl(r.recipeImage),
    dietary_tags: extractDietaryTags(r),
  }));

  return rows;
}

/**
 * Sync one meal period for the given date range
 */
async function syncMealPeriod(config, startDate, endDate) {
  console.log(`\n${"=".repeat(70)}`);
  console.log(`🍽️  SYNCING: ${config.name}`);
  console.log(`${"=".repeat(70)}`);

  try {
    // Fetch data from FD API
    const json = await fetchFDRange(config, startDate, endDate);

    const results = json.result || [];
    console.log(`[${config.name}] ✅ FD returned ${results.length} day entries`);

    if (results.length === 0) {
      console.log(`[${config.name}] ⚠️  No data returned from FD API`);
      return { success: true, inserted: 0 };
    }

    // Process each day
    const allRows = [];
    for (const day of results) {
      const rowsForDay = processMenuItems(config, day);
      allRows.push(...rowsForDay);
    }

    // Deduplicate BEFORE inserting
    const beforeDedup = allRows.length;
    const dedupedRows = deduplicateRows(allRows);
    const afterDedup = dedupedRows.length;

    if (beforeDedup !== afterDedup) {
      console.log(
        `[${config.name}] 🔄 Deduplication: ${beforeDedup} → ${afterDedup} rows ` +
          `(removed ${beforeDedup - afterDedup} duplicates)`
      );
    }

    if (dedupedRows.length === 0) {
      console.log(`[${config.name}] ℹ️  No rows to insert after filtering`);
      return { success: true, inserted: 0 };
    }

    // Insert into Supabase (will skip duplicates due to unique constraint)
    console.log(
      `[${config.name}] 💾 Inserting ${dedupedRows.length} rows into Supabase...`
    );

    const { data, error } = await supabase
  .from("dining_menu_items")
  .insert(dedupedRows)
  .select();

    if (error) {
      console.error(`[${config.name}] ❌ Supabase error:`, error.message);
      return { success: false, error: error.message };
    }

    const insertedCount = data?.length ?? 0;
    console.log(`[${config.name}] ✅ Successfully processed ${insertedCount} rows`);

    return { success: true, inserted: insertedCount };
  } catch (err) {
    console.error(`[${config.name}] ❌ Unexpected error:`, err.message);
    return { success: false, error: err.message };
  }
}

// ============================================================================
// CLEANUP FUNCTIONS
// ============================================================================

/**
 * Delete existing data for the date range to avoid duplicates on re-sync
 */
async function clearExistingData(startDate, endDate) {
  const startStr = formatFDDate(startDate).replace(/\//g, "-");
  const endStr = formatFDDate(endDate).replace(/\//g, "-");

  console.log(`\n${"=".repeat(70)}`);
  console.log(`🗑️  CLEANING UP EXISTING DATA`);
  console.log(`${"=".repeat(70)}`);
  console.log(`📅 Date range: ${startStr} to ${endStr}`);

  try {
    const { data, error } = await supabase
      .from("dining_menu_items")
      .delete()
      .gte("served_on", startStr)
      .lte("served_on", endStr)
      .select();

    if (error) {
      console.error("❌ Error clearing existing data:", error.message);
      return { success: false, error: error.message };
    }

    const deletedCount = data?.length ?? 0;
    console.log(`✅ Deleted ${deletedCount} existing rows`);

    return { success: true, deleted: deletedCount };
  } catch (err) {
    console.error("❌ Unexpected error during cleanup:", err.message);
    return { success: false, error: err.message };
  }
}

// ============================================================================
// MAIN EXECUTION
// ============================================================================

async function main() {
  console.log("\n" + "=".repeat(70));
  console.log("🚀 GETTYSBURG DINING MENU SYNC - FINAL VERSION");
  console.log("=".repeat(70));

 // Date range: today through 6 days from now (7-day weekly window)
const today = new Date();
const endDate = new Date(today);
endDate.setDate(endDate.getDate() + 6);

console.log(`📅 Syncing next 7 days: ${formatFDDate(today)} → ${formatFDDate(endDate)}`);

  // Step 1: Clear existing data for this range
  const clearResult = await clearExistingData(today, endDate);
  if (!clearResult.success) {
    console.error("❌ Failed to clear existing data. Aborting.");
    process.exit(1);
  }

  // Step 2: Sync all meal periods
  const results = [];
  for (const config of MEAL_CONFIGS) {
    const result = await syncMealPeriod(config, today, endDate);
    results.push({ name: config.name, ...result });
  }

  // Step 3: Print summary
  console.log("\n" + "=".repeat(70));
  console.log("📊 SYNC SUMMARY");
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
  console.log(`🎉 TOTAL: ${totalInserted} rows inserted`);
  if (failures > 0) {
    console.log(`⚠️  ${failures} meal period(s) had errors`);
  }
  console.log("=".repeat(70) + "\n");

  if (failures > 0) {
    process.exit(1);
  }
}

main();
