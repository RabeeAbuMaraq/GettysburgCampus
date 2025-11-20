#!/usr/bin/env node

/**
 * Test script for AI filter
 * 
 * Usage:
 *   export GOOGLE_API_KEY="your-key"
 *   node test_ai_filter.mjs
 */

import { classifyItemsWithAI } from "./ai_filter.mjs";

// Sample item data (similar to what would come from a weekly sync)
const sampleItems = [
  {
    name: "Cheesesteak",
    days_count: 1,
    dates: ["2025-11-19"],
    locations: ["Bullet Hole"],
    meal_periods: ["Lunch"],
    has_image: true,
  },
  {
    name: "Penne Pasta",
    days_count: 7,
    dates: ["2025-11-19", "2025-11-20", "2025-11-21", "2025-11-22", "2025-11-23", "2025-11-24", "2025-11-25"],
    locations: ["Bullet Hole"],
    meal_periods: ["Lunch"],
    has_image: true,
  },
  {
    name: "Shredded Lettuce",
    days_count: 7,
    dates: ["2025-11-19", "2025-11-20", "2025-11-21", "2025-11-22", "2025-11-23", "2025-11-24", "2025-11-25"],
    locations: ["Bullet Hole"],
    meal_periods: ["Lunch"],
    has_image: true,
  },
  {
    name: "Bibimbap Chicken - BH",
    days_count: 2,
    dates: ["2025-11-19", "2025-11-22"],
    locations: ["Bullet Hole"],
    meal_periods: ["Lunch"],
    has_image: true,
  },
  {
    name: "Ranch Dressing",
    days_count: 7,
    dates: ["2025-11-19", "2025-11-20", "2025-11-21", "2025-11-22", "2025-11-23", "2025-11-24", "2025-11-25"],
    locations: ["Bullet Hole"],
    meal_periods: ["Lunch"],
    has_image: true,
  },
  {
    name: "Jumbo Chicken Wings",
    days_count: 1,
    dates: ["2025-11-20"],
    locations: ["Bullet Hole"],
    meal_periods: ["Lunch"],
    has_image: true,
  },
  {
    name: "Red Pepper and Smoked Gouda Soup",
    days_count: 1,
    dates: ["2025-11-21"],
    locations: ["Servo"],
    meal_periods: ["Lunch"],
    has_image: true,
  },
  {
    name: "Chicken Breast",
    days_count: 7,
    dates: ["2025-11-19", "2025-11-20", "2025-11-21", "2025-11-22", "2025-11-23", "2025-11-24", "2025-11-25"],
    locations: ["Bullet Hole"],
    meal_periods: ["Lunch"],
    has_image: true,
  },
];

async function test() {
  console.log("=".repeat(70));
  console.log("🧪 TESTING AI FILTER");
  console.log("=".repeat(70));
  console.log();

  // Check for API key
  if (!process.env.GOOGLE_API_KEY) {
    console.warn("⚠️  GOOGLE_API_KEY not set. Will test fallback heuristic.");
  } else {
    console.log("✅ GOOGLE_API_KEY found");
  }

  console.log();
  console.log("📋 Sample Items:");
  for (const item of sampleItems) {
    console.log(`  • ${item.name} (${item.days_count} days)`);
  }

  console.log();
  console.log("🤖 Calling AI classifier...");
  console.log();

  const decisions = await classifyItemsWithAI({
    location: "Bullet Hole",
    mealPeriod: "Lunch",
    items: sampleItems,
  });

  console.log();
  console.log("=".repeat(70));
  console.log("📊 RESULTS");
  console.log("=".repeat(70));
  console.log();

  const kept = [];
  const hidden = [];

  for (const item of sampleItems) {
    const decision = decisions.get(item.name);
    if (!decision) {
      console.log(`⚠️  ${item.name}: No decision returned`);
      continue;
    }

    const emoji = decision.keep ? "✅" : "❌";
    console.log(`${emoji} ${item.name}`);
    console.log(`   Days: ${item.days_count}, Decision: ${decision.keep ? "KEEP" : "HIDE"}`);
    console.log(`   Reason: ${decision.reason}`);
    console.log();

    if (decision.keep) {
      kept.push(item.name);
    } else {
      hidden.push(item.name);
    }
  }

  console.log("=".repeat(70));
  console.log(`📊 SUMMARY: ${kept.length} kept, ${hidden.length} hidden`);
  console.log("=".repeat(70));
  console.log();
  console.log("✅ Items to show in app:");
  for (const name of kept) {
    console.log(`   • ${name}`);
  }
  console.log();
  console.log("❌ Items hidden from app:");
  for (const name of hidden) {
    console.log(`   • ${name}`);
  }
  console.log();

  // Expected results (when AI works correctly)
  const expectedKeep = new Set([
    "Cheesesteak",
    "Bibimbap Chicken - BH",
    "Jumbo Chicken Wings",
    "Red Pepper and Smoked Gouda Soup",
  ]);

  const expectedHide = new Set([
    "Penne Pasta",
    "Shredded Lettuce",
    "Ranch Dressing",
    "Chicken Breast",
  ]);

  console.log("🎯 VALIDATION:");
  let correct = 0;
  let incorrect = 0;

  for (const name of kept) {
    if (expectedKeep.has(name)) {
      console.log(`   ✅ Correctly kept: ${name}`);
      correct++;
    } else {
      console.log(`   ⚠️  Unexpectedly kept: ${name}`);
      incorrect++;
    }
  }

  for (const name of hidden) {
    if (expectedHide.has(name)) {
      console.log(`   ✅ Correctly hidden: ${name}`);
      correct++;
    } else {
      console.log(`   ⚠️  Unexpectedly hidden: ${name}`);
      incorrect++;
    }
  }

  console.log();
  console.log(`📈 Accuracy: ${correct}/${correct + incorrect} (${Math.round(100 * correct / (correct + incorrect))}%)`);
  console.log();
}

test().catch((error) => {
  console.error("❌ Test failed:", error.message);
  console.error(error.stack);
  process.exit(1);
});

