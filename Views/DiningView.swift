import SwiftUI

struct DiningView: View {
    @StateObject private var repo = DiningRepository()
    @State private var date = Date()

    var body: some View {
        NavigationStack {
            List {
                Section("Date") {
                    DatePicker("", selection: $date, displayedComponents: .date)
                        .labelsHidden()
                        .onChange(of: date) { _, d in Task { await repo.load(date: d) } }
                }
                ForEach(FDConfig.locations, id: \.id) { loc in
                    Section(loc.name) {
                        if let periods = repo.periodsByLocation[loc.id], !periods.isEmpty {
                            ForEach(periods, id: \.id) { p in
                                let key = "\(loc.id)-\(p.id)-\(DiningRepository.format(date))"
                                NavigationLink("\(p.name)") {
                                    MenuItemsListView(
                                        title: "\(loc.name) • \(p.name)",
                                        items: repo.itemsByKey[key] ?? []
                                    )
                                }
                            }
                        } else {
                            Text("Loading meal periods...")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Campus Dining")
            .task { await repo.load(date: date) }
            .refreshable { await repo.load(date: date) }
        }
    }
}

struct MenuItemsListView: View {
    let title: String
    let items: [FDMealItem]
    var body: some View {
        List(items, id: \.id) { it in
            VStack(alignment: .leading, spacing: 4) {
                Text(it.name).font(.headline)
                if let s = it.station { Text(s).font(.subheadline) }
                if let d = it.description, !d.isEmpty { Text(d).font(.footnote) }
                HStack(spacing: 8) {
                    if let c = it.calories { Text("\(c) cal").font(.caption) }
                    if let a = it.attributes, !a.isEmpty { Text(a.joined(separator: " • ")).font(.caption) }
                    if let g = it.allergens, !g.isEmpty { Text("Allergens: " + g.joined(separator: ", ")).font(.caption) }
                }
            }
        }
        .navigationTitle(title)
    }
}


