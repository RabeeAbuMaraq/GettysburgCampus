### Gettysburg Campus App — Android (Java) News Section Patterns

This document rewrites the SwiftUI news patterns in Java for Android. It includes:

- Four plug‑and‑play styles: Carousel, Stacked Deck, Inline Ticker, Hero + Grid
- `NewsItem` model
- Reusable adapters and helpers (Glide for images, Chrome Custom Tabs for web)
- Minimal XML layouts
- Gradle dependencies

You can copy these snippets into an Android module or project. Each style can be embedded inside a Fragment/Activity layout or a custom view.

---

#### Gradle dependencies (Module: app)

```gradle
dependencies {
    implementation 'androidx.appcompat:appcompat:1.7.0'
    implementation 'com.google.android.material:material:1.12.0'
    implementation 'androidx.recyclerview:recyclerview:1.3.2'
    implementation 'androidx.viewpager2:viewpager2:1.1.0'

    // Images
    implementation 'com.github.bumptech.glide:glide:4.16.0'
    annotationProcessor 'com.github.bumptech.glide:compiler:4.16.0'

    // In‑app browser
    implementation 'androidx.browser:browser:1.8.0'
}
```

---

#### Model: `NewsItem.java`

```java
package com.gettysburgcampus.news;

import java.net.URL;
import java.util.Date;
import java.util.Objects;

public class NewsItem {
    public final String id;
    public final String title;
    public final String subtitle; // optional
    public final URL imageURL;     // optional
    public final Date publishedAt;
    public final URL url;          // optional
    public final String source;    // optional
    public final String category;  // optional

    public NewsItem(String id,
                    String title,
                    String subtitle,
                    URL imageURL,
                    Date publishedAt,
                    URL url,
                    String source,
                    String category) {
        this.id = id;
        this.title = title;
        this.subtitle = subtitle;
        this.imageURL = imageURL;
        this.publishedAt = publishedAt;
        this.url = url;
        this.source = source;
        this.category = category;
    }

    @Override public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof NewsItem)) return false;
        NewsItem that = (NewsItem) o;
        return Objects.equals(id, that.id);
    }

    @Override public int hashCode() { return Objects.hash(id); }
}
```

---

#### Helpers: `ImageLoader.java` and `Browser.java`

```java
package com.gettysburgcampus.news;

import android.content.Context;
import android.widget.ImageView;
import com.bumptech.glide.Glide;
import com.bumptech.glide.load.resource.drawable.DrawableTransitionOptions;

public final class ImageLoader {
    private ImageLoader() {}

    public static void load(ImageView view, String url) {
        if (url == null || url.isEmpty()) return;
        Glide.with(view.getContext())
             .load(url)
             .transition(DrawableTransitionOptions.withCrossFade())
             .centerCrop()
             .into(view);
    }
}
```

```java
package com.gettysburgcampus.news;

import android.content.Context;
import android.net.Uri;
import androidx.browser.customtabs.CustomTabsIntent;

public final class Browser {
    private Browser() {}

    public static void open(Context context, String url) {
        if (url == null || url.isEmpty()) return;
        CustomTabsIntent intent = new CustomTabsIntent.Builder().build();
        intent.launchUrl(context, Uri.parse(url));
    }
}
```

---

#### Layouts

`res/layout/item_news_card.xml` — large card with image and overlays

```xml
<?xml version="1.0" encoding="utf-8"?>
<FrameLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="220dp">

    <ImageView
        android:id="@+id/image"
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:scaleType="centerCrop" />

    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:layout_gravity="bottom"
        android:orientation="vertical"
        android:padding="16dp"
        android:background="@android:color/transparent">

        <LinearLayout
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:orientation="horizontal">

            <TextView
                android:id="@+id/category"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:textColor="#FFFFFFFF"
                android:textSize="10sp"
                android:paddingLeft="8dp"
                android:paddingRight="8dp"
                android:paddingTop="4dp"
                android:paddingBottom="4dp"
                android:background="@android:color/transparent" />

            <Space
                android:layout_width="0dp"
                android:layout_height="0dp"
                android:layout_weight="1" />

            <TextView
                android:id="@+id/time"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:textColor="#B3FFFFFF"
                android:textSize="10sp" />
        </LinearLayout>

        <TextView
            android:id="@+id/title"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:textColor="#FFFFFFFF"
            android:textSize="16sp"
            android:textStyle="bold"
            android:maxLines="2" />

        <TextView
            android:id="@+id/subtitle"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:textColor="#E6FFFFFF"
            android:textSize="13sp"
            android:maxLines="2"
            android:visibility="gone" />
    </LinearLayout>
</FrameLayout>
```

`res/layout/item_news_compact.xml` — compact horizontal card

```xml
<?xml version="1.0" encoding="utf-8"?>
<FrameLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="260dp"
    android:layout_height="140dp">

    <ImageView
        android:id="@+id/image"
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:scaleType="centerCrop" />

    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:layout_gravity="bottom"
        android:orientation="vertical"
        android:padding="12dp">

        <TextView
            android:id="@+id/title"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:textColor="#FFFFFFFF"
            android:textSize="14sp"
            android:textStyle="bold"
            android:maxLines="2" />

        <TextView
            android:id="@+id/time"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:textColor="#E6FFFFFF"
            android:textSize="11sp" />
    </LinearLayout>
</FrameLayout>
```

`res/layout/view_news_showcase.xml` — host container that toggles styles

```xml
<?xml version="1.0" encoding="utf-8"?>
<FrameLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:id="@+id/root"
    android:layout_width="match_parent"
    android:layout_height="wrap_content" />
```

---

#### Adapters (Java)

`NewsCarouselAdapter.java` — for ViewPager2 pages (large cards)

```java
package com.gettysburgcampus.news;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;
import java.text.SimpleDateFormat;
import java.util.List;
import java.util.Locale;

public class NewsCarouselAdapter extends RecyclerView.Adapter<NewsCarouselAdapter.VH> {
    public interface OnItemClick { void onClick(NewsItem item); }
    private final List<NewsItem> items;
    private final OnItemClick onClick;
    private final SimpleDateFormat rel = new SimpleDateFormat("MMM d", Locale.getDefault());

    public NewsCarouselAdapter(List<NewsItem> items, OnItemClick onClick) {
        this.items = items; this.onClick = onClick;
    }

    @NonNull @Override public VH onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View v = LayoutInflater.from(parent.getContext()).inflate(R.layout.item_news_card, parent, false);
        return new VH(v);
    }

    @Override public void onBindViewHolder(@NonNull VH h, int position) {
        NewsItem it = items.get(position);
        h.title.setText(it.title);
        if (it.subtitle != null && !it.subtitle.isEmpty()) {
            h.subtitle.setVisibility(View.VISIBLE);
            h.subtitle.setText(it.subtitle);
        } else {
            h.subtitle.setVisibility(View.GONE);
        }
        h.category.setText(it.category != null ? it.category.toUpperCase(Locale.getDefault()) : "");
        h.time.setText(rel.format(it.publishedAt));
        ImageLoader.load(h.image, it.imageURL != null ? it.imageURL.toString() : null);
        h.itemView.setOnClickListener(v -> onClick.onClick(it));
    }

    @Override public int getItemCount() { return items.size(); }

    static class VH extends RecyclerView.ViewHolder {
        ImageView image; TextView title; TextView subtitle; TextView category; TextView time;
        VH(@NonNull View itemView) {
            super(itemView);
            image = itemView.findViewById(R.id.image);
            title = itemView.findViewById(R.id.title);
            subtitle = itemView.findViewById(R.id.subtitle);
            category = itemView.findViewById(R.id.category);
            time = itemView.findViewById(R.id.time);
        }
    }
}
```

`NewsCompactAdapter.java` — for horizontal ticker and 2x2 grid

```java
package com.gettysburgcampus.news;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;
import java.text.SimpleDateFormat;
import java.util.List;
import java.util.Locale;

public class NewsCompactAdapter extends RecyclerView.Adapter<NewsCompactAdapter.VH> {
    public interface OnItemClick { void onClick(NewsItem item); }
    private final List<NewsItem> items; private final OnItemClick onClick;
    private final SimpleDateFormat rel = new SimpleDateFormat("MMM d", Locale.getDefault());

    public NewsCompactAdapter(List<NewsItem> items, OnItemClick onClick) {
        this.items = items; this.onClick = onClick;
    }

    @NonNull @Override public VH onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View v = LayoutInflater.from(parent.getContext()).inflate(R.layout.item_news_compact, parent, false);
        return new VH(v);
    }

    @Override public void onBindViewHolder(@NonNull VH h, int position) {
        NewsItem it = items.get(position);
        h.title.setText(it.title);
        h.time.setText(rel.format(it.publishedAt));
        ImageLoader.load(h.image, it.imageURL != null ? it.imageURL.toString() : null);
        h.itemView.setOnClickListener(v -> onClick.onClick(it));
    }

    @Override public int getItemCount() { return items.size(); }

    static class VH extends RecyclerView.ViewHolder {
        ImageView image; TextView title; TextView time;
        VH(@NonNull View itemView) {
            super(itemView);
            image = itemView.findViewById(R.id.image);
            title = itemView.findViewById(R.id.title);
            time = itemView.findViewById(R.id.time);
        }
    }
}
```

---

#### Custom View: `NewsShowcaseView.java`

This view switches between the four styles. Embed it in your Home screen layout.

```java
package com.gettysburgcampus.news;

import android.content.Context;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.FrameLayout;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import androidx.viewpager2.widget.CompositePageTransformer;
import androidx.viewpager2.widget.MarginPageTransformer;
import androidx.viewpager2.widget.ViewPager2;
import com.google.android.material.tabs.TabLayout;
import com.google.android.material.tabs.TabLayoutMediator;
import java.util.ArrayList;
import java.util.List;

public class NewsShowcaseView extends FrameLayout {
    public enum Style { CAROUSEL, STACKED_DECK, INLINE_TICKER, HERO_GRID }

    private final LayoutInflater inflater;
    private final List<NewsItem> items = new ArrayList<>();
    private Style style = Style.CAROUSEL;
    private OnSeeAllClick onSeeAllClick;

    public interface OnSeeAllClick { void onClick(); }

    public NewsShowcaseView(Context context) { this(context, null); }
    public NewsShowcaseView(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        inflater = LayoutInflater.from(context);
        inflater.inflate(R.layout.view_news_showcase, this, true);
        setClipToPadding(false);
    }

    public void setStyle(Style style) { this.style = style; render(); }
    public void setItems(List<NewsItem> newItems) { items.clear(); items.addAll(newItems); render(); }
    public void setOnSeeAllClick(OnSeeAllClick cb) { this.onSeeAllClick = cb; }

    private void render() {
        removeAllViews();
        switch (style) {
            case CAROUSEL: inflateCarousel(); break;
            case STACKED_DECK: inflateStackedDeck(); break;
            case INLINE_TICKER: inflateInlineTicker(); break;
            case HERO_GRID: inflateHeroGrid(); break;
        }
    }

    private void inflateCarousel() {
        View root = inflater.inflate(R.layout.view_news_showcase, this, false);
        addView(root);

        ViewPager2 pager = new ViewPager2(getContext());
        pager.setLayoutParams(new LayoutParams(LayoutParams.MATCH_PARENT, dp(220)));
        pager.setAdapter(new NewsCarouselAdapter(items, item -> Browser.open(getContext(), item.url != null ? item.url.toString() : null)));
        pager.setOffscreenPageLimit(1);
        addView(pager);

        TabLayout dots = new TabLayout(getContext());
        addView(dots);
        new TabLayoutMediator(dots, pager, (tab, position) -> {}).attach();
    }

    private void inflateStackedDeck() {
        ViewPager2 pager = new ViewPager2(getContext());
        pager.setLayoutParams(new LayoutParams(LayoutParams.MATCH_PARENT, dp(210)));
        pager.setAdapter(new NewsCarouselAdapter(items, item -> Browser.open(getContext(), item.url != null ? item.url.toString() : null)));
        pager.setClipToPadding(false);
        pager.setClipChildren(false);
        pager.setOffscreenPageLimit(3);

        CompositePageTransformer transformer = new CompositePageTransformer();
        transformer.addTransformer(new MarginPageTransformer(dp(12)));
        transformer.addTransformer((page, position) -> {
            float r = 1 - Math.abs(position);
            page.setScaleY(0.92f + r * 0.08f);
            page.setTranslationY(Math.abs(position) * dp(10));
            page.setElevation(10 - Math.abs(position) * 5);
        });
        pager.setPageTransformer(transformer);
        addView(pager);
    }

    private void inflateInlineTicker() {
        RecyclerView rv = new RecyclerView(getContext());
        rv.setLayoutParams(new LayoutParams(LayoutParams.MATCH_PARENT, dp(160)));
        rv.setLayoutManager(new LinearLayoutManager(getContext(), RecyclerView.HORIZONTAL, false));
        rv.setAdapter(new NewsCompactAdapter(items, item -> Browser.open(getContext(), item.url != null ? item.url.toString() : null)));
        addView(rv);
    }

    private void inflateHeroGrid() {
        // Simple approach: one horizontal ticker with the first item highlighted separately
        // You can also create a dedicated layout with ConstraintLayout and a nested grid
        RecyclerView grid = new RecyclerView(getContext());
        grid.setLayoutParams(new LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT));
        GridLayoutManager glm = new GridLayoutManager(getContext(), 2);
        grid.setLayoutManager(glm);
        // Reuse compact adapter for the grid; use items.subList(1, ...) if you also render a hero separately
        grid.setAdapter(new NewsCompactAdapter(items, item -> Browser.open(getContext(), item.url != null ? item.url.toString() : null)));
        addView(grid);
    }

    private int dp(int v) { return Math.round(getResources().getDisplayMetrics().density * v); }
}
```

---

#### Usage example (Activity XML)

`res/layout/activity_home.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<ScrollView xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent">

    <LinearLayout
        android:orientation="vertical"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:padding="16dp">

        <com.gettysburgcampus.news.NewsShowcaseView
            android:id="@+id/newsShowcase"
            android:layout_width="match_parent"
            android:layout_height="wrap_content" />

    </LinearLayout>
</ScrollView>
```

`HomeActivity.java`

```java
package com.gettysburgcampus;

import android.os.Bundle;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import com.gettysburgcampus.news.NewsItem;
import com.gettysburgcampus.news.NewsShowcaseView;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

public class HomeActivity extends AppCompatActivity {
    @Override protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_home);

        NewsShowcaseView showcase = findViewById(R.id.newsShowcase);
        showcase.setStyle(NewsShowcaseView.Style.CAROUSEL); // Try STACKED_DECK, INLINE_TICKER, HERO_GRID
        showcase.setOnSeeAllClick(() -> {/* navigate to All News */});
        showcase.setItems(sample());
    }

    private List<NewsItem> sample() {
        List<NewsItem> list = new ArrayList<>();
        try {
            list.add(new NewsItem("1", "First-years move in and Orientation kicks off", "Welcome events across campus all week",
                    new URL("https://images.unsplash.com/photo-1529336953121-a0ce10cd890b?q=80&w=1400&auto=format&fit=crop"), new Date(System.currentTimeMillis()-3600_000), new URL("https://www.gettysburg.edu"), "Gettysburg College", "Campus"));
            list.add(new NewsItem("2", "Dining adds new meal plan options", "More flexibility for busy schedules",
                    new URL("https://images.unsplash.com/photo-1504384308090-c894fdcc538d?q=80&w=1400&auto=format&fit=crop"), new Date(System.currentTimeMillis()-7200_000), new URL("https://www.gettysburg.edu"), "Campus Life", "Dining"));
            list.add(new NewsItem("3", "Bullets earn win on opening night", "Strong defense seals the game",
                    new URL("https://images.unsplash.com/photo-1502877338535-766e1452684a?q=80&w=1400&auto=format&fit=crop"), new Date(System.currentTimeMillis()-10800_000), new URL("https://www.gettysburg.edu"), "Athletics", "Sports"));
            list.add(new NewsItem("4", "Library extends hours for midterms", "Quiet study zones available",
                    new URL("https://images.unsplash.com/photo-1529156069898-49953e39b3ac?q=80&w=1400&auto=format&fit=crop"), new Date(System.currentTimeMillis()-160_000_000), new URL("https://www.gettysburg.edu"), "Musselman Library", "Academics"));
        } catch (MalformedURLException ignored) {}
        return list;
    }
}
```

---

#### Notes

- Carousel uses `ViewPager2` (with optional `TabLayout` dots via `TabLayoutMediator`).
- Stacked Deck uses `ViewPager2` with a `CompositePageTransformer` to scale/offset pages, creating an overlapping stack vibe.
- Inline Ticker is a horizontal `RecyclerView` with compact cards.
- Hero + Grid reuses the compact adapter in a `GridLayoutManager` (2 columns). You can split hero + grid explicitly if you prefer.
- Links open via Chrome Custom Tabs (`androidx.browser:browser`), the closest analogue to iOS `SFSafariViewController`.
- Images load with Glide and cross‑fade to avoid layout jumps.


