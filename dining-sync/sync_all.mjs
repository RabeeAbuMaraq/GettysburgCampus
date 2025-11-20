import { createClient } from "@supabase/supabase-js";

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

// === Bullet Hole: Always-available items to EXCLUDE ===
// These are bar items that are available every day and should not appear
// as daily specials. This includes pasta bar, salad bar, deli bar, toppings,
// condiments, and standard sides that never change.
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
// Similar to Bullet Hole, these are items always available at the grill,
// pasta bar, or as standard sides. We only want to show true daily specials.
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
  "Grilled Mediterranean Chicken Breast",
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
    locationName: "Servo",
    exclusionList: SERVO_ALWAYS_AVAILABLE,
  },
  {
    name: "Servo Dinner",
    accountId: "4",
    locationId: "4",
    mealPeriodId: "5",
    mealPeriodLabel: "Dinner",
    locationName: "Servo",
    exclusionList: SERVO_ALWAYS_AVAILABLE,
  },
  {
    name: "Bullet Lunch",
    accountId: "1",
    locationId: "1",
    mealPeriodId: "4",
    mealPeriodLabel: "Lunch",
    locationName: "Bullet Hole",
    exclusionList: BULLET_ALWAYS_AVAILABLE,
  },
  {
    name: "Bullet Dinner",
    accountId: "1",
    locationId: "1",
    mealPeriodId: "5",
    mealPeriodLabel: "Dinner",
    locationName: "Bullet Hole",
    exclusionList: BULLET_ALWAYS_AVAILABLE,
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
  const served_on = convertFDDateToDB(dayData.strMenuForDate);
  const location = config.locationName;
  const meal_period = config.mealPeriodLabel;

  // Handle both possible field names for recipes array
  const allRecipes = dayData.allMenuRecipes || dayData.menuRecipiesData || [];

  // STEP 1: Filter OUT bar items (isFoodBar === "1")
  // This is the KEY filter - bar items are always available
  const nonBarItems = allRecipes.filter((r) => r.isFoodBar !== "1");

  // STEP 2: Filter to daily special categories only
  // Categories that represent daily specials, not regular menu items
  const DAILY_SPECIAL_CATEGORIES = new Set([
    " Soup of the Day ",
    "Soup of the Day",
    " Entree",
    "Entree",
    " Salad of the Day ",
    "Salad of the Day",
    " Side", // Daily special sides (when not foodBar)
    "Side",
    " Dessert", // Daily special desserts (when not foodBar)
    "Dessert",
  ]);

  const dailySpecials = nonBarItems.filter((r) => {
    const category = (r.category || "").trim();
    return DAILY_SPECIAL_CATEGORIES.has(category);
  });

  // STEP 3: Apply exclusion list for extra safety
  // (catches specific items that might slip through)
  let filtered = dailySpecials;
  if (config.exclusionList) {
    filtered = dailySpecials.filter((r) => {
      const name = (
        r.componentEnglishName ||
        r.englishAlternateName ||
        r.componentName ||
        ""
      ).trim();
      if (!name) return false;

      // Exclude known always-available items
      if (config.exclusionList.has(name)) {
        return false;
      }

      return true;
    });
  }

  // STEP 4: Require valid image URL
  const withImages = filtered.filter((r) => !!r.recipeImagePath || !!r.recipeImage);

  // STEP 5: Deduplicate within this day's data using normalized names
  const seenNormalizedNames = new Set();
  const uniqueItems = [];

  for (const r of withImages) {
    const itemName =
      r.componentEnglishName ||
      r.englishAlternateName ||
      r.componentName ||
      "Unknown";
    
    const normalizedName = normalizeItemName(itemName);
    
    // Skip if we've already seen this item (normalized) for this day/meal
    if (seenNormalizedNames.has(normalizedName)) {
      continue;
    }
    
    seenNormalizedNames.add(normalizedName);
    uniqueItems.push(r);
  }

  // Log detailed filtering stats
  const duplicatesInDay = withImages.length - uniqueItems.length;
  console.log(
    `[${config.name}] 📊 ${served_on}: ` +
      `${allRecipes.length} total → ` +
      `${nonBarItems.length} non-bar → ` +
      `${dailySpecials.length} daily specials → ` +
      `${filtered.length} after exclusions → ` +
      `${withImages.length} with images → ` +
      `${uniqueItems.length} unique${duplicatesInDay > 0 ? ` (-${duplicatesInDay} dupes)` : ""}`
  );

  // STEP 6: Map to our database schema
  const rows = uniqueItems.map((r) => {
    const itemName =
      r.componentEnglishName ||
      r.englishAlternateName ||
      r.componentName ||
      "Unknown";
    const imagePath = r.recipeImagePath || r.recipeImage || "";

    return {
      served_on,
      location,
      meal_period,
      item_name: itemName.trim(),
      image_url: buildImageUrl(imagePath),
      dietary_tags: extractDietaryTags(r),
    };
  });

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

    // Final cross-day deduplication (should be minimal if per-day dedup works)
    const dedupMap = new Map();
    for (const row of allRows) {
      const key = `${row.served_on}|${normalizeItemName(row.item_name)}`;
      if (!dedupMap.has(key)) {
        dedupMap.set(key, row);
      }
    }
    const dedupedRows = Array.from(dedupMap.values());
    
    const crossDayDupes = allRows.length - dedupedRows.length;
    if (crossDayDupes > 0) {
      console.log(`[${config.name}] 🔄 Removed ${crossDayDupes} cross-day duplicate(s)`);
    }

    if (dedupedRows.length === 0) {
      console.log(`[${config.name}] ℹ️  No rows to insert after filtering`);
      return { success: true, inserted: 0 };
    }

    // Show summary by date
    const itemsByDate = {};
    for (const row of dedupedRows) {
      if (!itemsByDate[row.served_on]) {
        itemsByDate[row.served_on] = [];
      }
      itemsByDate[row.served_on].push(row.item_name);
    }
    
    console.log(`[${config.name}] 📋 Summary:`);
    for (const [date, items] of Object.entries(itemsByDate)) {
      console.log(`   ${date}: ${items.length} items - ${items.join(", ")}`);
    }

    // Insert into Supabase (simple insert, no upsert)
    // The date range was already cleared, so this should be clean
    console.log(
      `[${config.name}] 💾 Inserting ${dedupedRows.length} total rows into Supabase...`
    );

    const { data, error } = await supabase
      .from("dining_menu_items")
      .insert(dedupedRows)
      .select();

    if (error) {
      console.error(`[${config.name}] ❌ Supabase error:`, error.message);
      console.error(`   Details:`, error);
      return { success: false, error: error.message };
    }

    const insertedCount = data?.length ?? 0;
    console.log(`[${config.name}] ✅ Successfully inserted ${insertedCount} rows`);

    return { success: true, inserted: insertedCount };
  } catch (err) {
    console.error(`[${config.name}] ❌ Unexpected error:`, err.message);
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
  console.log(`⚠️  This will delete ALL menu items from the database`);

  try {
    // Delete all rows
    const { data, error } = await supabase
      .from("dining_menu_items")
      .delete()
      .neq("id", 0) // Delete everything (id != 0 means all rows)
      .select();

    if (error) {
      console.error("❌ Error clearing data:", error.message);
      return { success: false, error: error.message };
    }

    const deletedCount = data?.length ?? 0;
    console.log(`✅ Deleted ${deletedCount} existing rows (fresh start)`);

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
