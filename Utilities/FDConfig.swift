import Foundation

enum FDConfig {
	// Tenant specific API
	static let apiBase = URL(string: "https://apiservicelocatorstenantgettysburg.fdmealplanner.com")!
	static let apiPrefix = "/api/v1/data-locator-webapi/19"

	// Token endpoint captured from DevTools
	static let tokenURL = URL(string: "https://users.fdmealplanner.com/api/v1/token-data/D4qSnj2SJXF2EEWw6tcxKG8oTvhtZ72moLq93YSARSvbUbBBgbDQ2DPngDFM3lh5/token")!

	// IDs
	static let accountId = 4
	static let tenantId = 19

	// Location ids confirmed by captures
	static let locations: [FDLocation] = [
		.init(id: 1, name: "Gettysburg - Bullet Hole"),
		.init(id: 2, name: "Gettysburg - Commons"),
		.init(id: 4, name: "Gettysburg - Servo")
	]
}


