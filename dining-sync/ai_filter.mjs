// ============================================================================
// AI-POWERED MENU ITEM CLASSIFIER
// Uses Google AI Studio (Gemini) to intelligently filter dining menu items
// ============================================================================

/**
 * @typedef {Object} MenuItem
 * @property {string} name - Item name
 * @property {number} days_count - Number of distinct days this item appears
 * @property {string[]} dates - List of dates in YYYY-MM-DD format
 * @property {string[]} locations - Set of location names
 * @property {string[]} meal_periods - Set of meal periods (Lunch/Dinner)
 * @property {boolean} has_image - Whether item has an image
 */

/**
 * @typedef {Object} AIDecision
 * @property {boolean} keep - Whether to keep this item in the menu
 * @property {string} reason - Human-readable explanation
 */

const GEMINI_ENDPOINT = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent";

/**
 * Build the AI prompt that explains the task and rules
 */
function buildPrompt(items, location, mealPeriod) {
  return `You are helping simplify a college dining app menu for Gettysburg College students. Your task is to decide which menu items are daily specials worth showing in the app, versus which are always-available bar staples or generic components that should be hidden.

CONTEXT:
- Location: ${location}
- Meal Period: ${mealPeriod}
- Date Range: ${items.length > 0 ? `${items[0].dates[0]} to ${items[0].dates[items[0].dates.length - 1]}` : "N/A"}

DECISION RULES:
1. **Hide bar staples and base ingredients**: If an item looks like a base ingredient, salad component, topping, sauce, side, or bar staple, mark it as "keep": false.
   Examples to HIDE: shredded lettuce, cheddar cheese, ranch dressing, white rice, penne pasta, hummus, french fries, burger patties, chicken breast, generic pizza toppings, pasta sauces, deli meats, breads/buns, condiments.

2. **Hide items that appear every day**: If an item appears every day or almost every day (days_count >= 6 in a 7-day window), and it looks generic, mark it as "keep": false.

3. **Keep named dishes and obvious specials**: If it is a named dish or obvious daily special, mark it as "keep": true.
   Examples to KEEP: "Cheesesteak", "Bibimbap Chicken - BH", "Jumbo Chicken Wings", "Red Pepper and Smoked Gouda Soup", "Breakfast Bowl", "Tomato Basil Bisque", "Gyro" (the daily special, not the bar cone), "Pulled Pork Sandwich", "Beef Tacos".

4. **When in doubt, hide it**: Lean toward hiding items (keep: false) so the app stays minimal and focused on true daily specials.

5. **Response format**: Return ONLY valid JSON, no markdown, no explanations outside the JSON structure.

INPUT DATA:
${JSON.stringify(items, null, 2)}

REQUIRED OUTPUT FORMAT (respond with ONLY this JSON, nothing else):
{
  "items": [
    { "name": "Item Name Here", "keep": true, "reason": "Brief explanation" },
    { "name": "Another Item", "keep": false, "reason": "Brief explanation" }
  ]
}

CRITICAL: Your response must include ALL ${items.length} items in the EXACT same order with the EXACT same names as the input.`;
}

/**
 * Call Google AI Studio API to classify menu items
 * 
 * @param {Object} params
 * @param {string} params.location - Location name (e.g., "Servo", "Bullet Hole")
 * @param {string} params.mealPeriod - Meal period (e.g., "Lunch", "Dinner")
 * @param {MenuItem[]} params.items - Array of item summaries to classify
 * @returns {Promise<Map<string, AIDecision>>} Map from item name to decision
 */
export async function classifyItemsWithAI({ location, mealPeriod, items }) {
  const apiKey = process.env.GOOGLE_API_KEY;

  // Short circuit: if no items or very few items, keep them all
  if (!items || items.length === 0) {
    console.log(`[AI] ${location} ${mealPeriod}: No items to classify`);
    return new Map();
  }

  if (items.length === 1) {
    console.log(`[AI] ${location} ${mealPeriod}: Only 1 item, auto-keeping`);
    const decision = new Map();
    decision.set(items[0].name, { keep: true, reason: "Only item available" });
    return decision;
  }

  // If API key is missing, use fallback heuristic
  if (!apiKey) {
    console.warn(`[AI] ⚠️  GOOGLE_API_KEY not set. Using fallback heuristic.`);
    return fallbackHeuristic(items, location, mealPeriod);
  }

  try {
    console.log(`[AI] 🤖 Calling Google AI Studio for ${location} ${mealPeriod} with ${items.length} items...`);

    const prompt = buildPrompt(items, location, mealPeriod);

    // Construct request body for Gemini API
    const requestBody = {
      contents: [
        {
          parts: [
            {
              text: prompt
            }
          ]
        }
      ],
      generationConfig: {
        temperature: 0.1, // Low temperature for consistent, deterministic results
        maxOutputTokens: 8192,
      }
    };

    const url = `${GEMINI_ENDPOINT}?key=${apiKey}`;

    const response = await fetch(url, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(requestBody),
    });

    if (!response.ok) {
      const errorText = await response.text();
      console.error(`[AI] ❌ API error: ${response.status} ${response.statusText}`);
      console.error(`[AI] Response: ${errorText}`);
      return fallbackHeuristic(items, location, mealPeriod);
    }

    const responseData = await response.json();

    // Extract text from Gemini response
    const candidates = responseData.candidates;
    if (!candidates || candidates.length === 0) {
      console.error(`[AI] ❌ No candidates in response`);
      return fallbackHeuristic(items, location, mealPeriod);
    }

    const content = candidates[0].content;
    if (!content || !content.parts || content.parts.length === 0) {
      console.error(`[AI] ❌ No content parts in response`);
      return fallbackHeuristic(items, location, mealPeriod);
    }

    let aiText = content.parts[0].text;
    if (!aiText) {
      console.error(`[AI] ❌ No text in response`);
      return fallbackHeuristic(items, location, mealPeriod);
    }

    // Clean up response: remove markdown code blocks if present
    aiText = aiText.trim();
    if (aiText.startsWith("```json")) {
      aiText = aiText.replace(/^```json\s*/i, "").replace(/```\s*$/, "");
    } else if (aiText.startsWith("```")) {
      aiText = aiText.replace(/^```\s*/, "").replace(/```\s*$/, "");
    }

    // Parse JSON response
    let aiResponse;
    try {
      aiResponse = JSON.parse(aiText);
    } catch (parseError) {
      console.error(`[AI] ❌ Failed to parse JSON response:`, parseError.message);
      console.error(`[AI] Raw response text:`, aiText.substring(0, 500));
      return fallbackHeuristic(items, location, mealPeriod);
    }

    // Validate response structure
    if (!aiResponse.items || !Array.isArray(aiResponse.items)) {
      console.error(`[AI] ❌ Response missing 'items' array`);
      return fallbackHeuristic(items, location, mealPeriod);
    }

    if (aiResponse.items.length !== items.length) {
      console.warn(
        `[AI] ⚠️  Response has ${aiResponse.items.length} items but expected ${items.length}. Using fallback.`
      );
      return fallbackHeuristic(items, location, mealPeriod);
    }

    // Build decision map
    const decisions = new Map();
    for (const item of aiResponse.items) {
      if (!item.name || typeof item.keep !== "boolean") {
        console.error(`[AI] ❌ Invalid item structure:`, item);
        continue;
      }
      decisions.set(item.name, {
        keep: item.keep,
        reason: item.reason || "No reason provided",
      });
    }

    console.log(`[AI] ✅ Parsed decisions for ${decisions.size} / ${items.length} items`);

    // Log sample decisions for debugging
    const samples = Array.from(decisions.entries()).slice(0, 5);
    console.log(`[AI] 📋 Sample decisions:`);
    for (const [name, decision] of samples) {
      const emoji = decision.keep ? "✅" : "❌";
      console.log(`[AI]   ${emoji} ${name}: ${decision.reason}`);
    }

    // Log summary stats
    const keepCount = Array.from(decisions.values()).filter(d => d.keep).length;
    const hideCount = decisions.size - keepCount;
    console.log(`[AI] 📊 Summary: Keep ${keepCount}, Hide ${hideCount}`);

    return decisions;

  } catch (error) {
    console.error(`[AI] ❌ Unexpected error:`, error.message);
    console.error(`[AI] Stack:`, error.stack);
    return fallbackHeuristic(items, location, mealPeriod);
  }
}

/**
 * Fallback heuristic when AI is unavailable or fails
 * Simple rule: hide items that appear >= 5 days in a 7-day window
 * 
 * @param {MenuItem[]} items
 * @param {string} location
 * @param {string} mealPeriod
 * @returns {Map<string, AIDecision>}
 */
function fallbackHeuristic(items, location, mealPeriod) {
  console.log(`[AI] 🔄 Using fallback heuristic for ${location} ${mealPeriod}`);
  
  const decisions = new Map();
  const FREQUENCY_THRESHOLD = 5; // Hide items appearing 5+ days per week

  for (const item of items) {
    const keep = item.days_count < FREQUENCY_THRESHOLD;
    decisions.set(item.name, {
      keep,
      reason: keep
        ? `Appears ${item.days_count} days (infrequent special)`
        : `Appears ${item.days_count} days (likely bar staple)`,
    });
  }

  const keepCount = Array.from(decisions.values()).filter(d => d.keep).length;
  console.log(`[AI] 📊 Fallback: Keep ${keepCount} / ${items.length} items`);

  return decisions;
}

